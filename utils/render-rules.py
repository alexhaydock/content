#!/usr/bin/python3

from __future__ import print_function

from glob import glob
import collections
import os
import re
import pathlib

import argparse

import ssg.build_yaml
import ssg.controls
import ssg.yaml
import ssg.jinja
import template_renderer


class HtmlOutput(template_renderer.Renderer):
    TEMPLATE_NAME = "rules-template.html"

    def _get_all_compiled_profiles(self):
        compiled_profiles = glob(str(self.built_content_path / "profiles" / "*.profile"))
        profiles = []
        for p in compiled_profiles:
            profiles.append(ssg.build_yaml.Profile.from_yaml(p, self.env_yaml))
        return profiles

    def _set_rule_profiles_membership(self, rule, profiles):
        rule.in_profiles = [p for p in profiles if rule.id_ in p.selected]

    def _resolve_var_substitutions(self, rule):
        # The <sub .../> here is not the HTML subscript element <sub>...</sub>,
        # and therefore is invalid HTML.
        # so this code substitutes the whole sub element with contents of its idref prefixed by $
        # as occurrence of sub with idref implies that substitution of XCCDF values takes place
        rule.description = re.sub(
            r'<sub\s+idref="([^"]*)"\s*/>', r"<tt>$\1</tt>", rule.description)

    def process_rules(self, rule_files):
        rules = []
        profiles = self._get_all_compiled_profiles()

        for r_file in rule_files:
            rule = ssg.build_yaml.Rule.from_yaml(r_file, self.env_yaml)
            self._set_rule_relative_definition_location(rule)
            self._set_rule_profiles_membership(rule, profiles)
            self._resolve_var_substitutions(rule)
            rules.append(rule)

        self.template_data["rules"] = rules


def parse_args():
    parser = HtmlOutput.create_parser(
        "Pass a list of rule YAMLs, and the script will "
        "render their summary as an HTML along with links to the usage of these rules in profiles "
        "and with links to the upstream rule source.")
    parser.add_argument(
        "rule", metavar="FILENAME", nargs="+", help="The rule YAML files")
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    renderer = HtmlOutput(args.product, args.build_dir)
    renderer.process_rules(args.rule)
    renderer.output_results(args)
