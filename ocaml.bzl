# Copyright 2015 Benjamin Barenblat.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

def _change_extension(path, new_extension):
  # TODO(bbarenblat): Don’t hard-code "/" as the path separator.
  basename_start = path.rfind("/")
  if basename_start == -1:
    basename_start = 0
  extension_start = path.rfind(".", basename_start)
  if extension_start == -1:
    # No extension, so add one.
    return path + "." + new_extension
  else:
    return path[:extension_start] + "." + new_extension

def _ocaml_interface_impl(ctx):
  # ocamlopt completely ignores the -o option if you’re compiling OCaml.  (It
  # works correctly if you’re compiling C using ocamlopt as a driver.)  As a
  # workaround, compute the path to the file ocamlopt will generate and then
  # move it into its final (Bazel-approved) location.
  input_file_path = ctx.files.src[0].path
  generated_interface_path = _change_extension(input_file_path, "cmi")
  cmd = (
      "set -e;" +
      "ocamlopt" +
      " -intf " + input_file_path + ";" +
      "mv " + generated_interface_path +
      " " + ctx.outputs.compiled_interface.path
  )
  ctx.action(
      inputs=[],
      outputs=[ctx.outputs.compiled_interface],
      progress_message="Compiling OCaml interface %s" % ctx.label.name,
      command=cmd,
  )

ocaml_interface = rule(
    implementation=_ocaml_interface_impl,
    attrs={
        "src": attr.label(allow_files=True, mandatory=True, single_file=True)
    },
    outputs={"compiled_interface": "%{src}.cmi"},
)
