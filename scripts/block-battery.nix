{ pkgs }:

pkgs.writeScriptBin "block-battery" ''
  #!${pkgs.python3}/bin/python3
  import os
  import re
  import subprocess
  import sys

  # Check if acpi is installed
  acpi_path = "${pkgs.acpi}/bin/acpi"

  config = dict(os.environ)

  try:
      status = subprocess.check_output([acpi_path], universal_newlines=True)
  except Exception:
      # No battery or acpi failed
      print("")
      sys.exit(0)

  if not status:
      sys.exit(0)

  # Simple parsing logic
  fulltext = ""
  percent = 0

  # Check for Discharging/Charging
  is_discharging = "Discharging" in status
  is_charging = "Charging" in status
  is_full = "Full" in status

  # Extract percentage
  match = re.search(r"(\d+)%", status)
  if match:
      percent = int(match.group(1))

  # Icons
  icon = ""
  if is_discharging:
      icon = "" # Battery
  elif is_charging:
      icon = "" # Lightning
  elif is_full:
      icon = "" # Plug
  else:
      icon = "" # Question

  # Color logic
  color = "#FFFFFF"
  if percent < 10:
      color = "#FF0000"
  elif percent < 20:
      color = "#FF3300"
  elif percent < 30:
      color = "#FF6600"
  elif percent < 50:
      color = "#FFCC00"
  elif percent < 80:
      color = "#FFFF00"

  # Format output
  print(f"<span color='{color}'>{icon} {percent}%</span>")

  if percent < 10 and is_discharging:
      sys.exit(33)
''
