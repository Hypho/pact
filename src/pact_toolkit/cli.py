from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from importlib.resources import files
from pathlib import Path


VALID_MODES = ("all", "claude", "codex", "cursor", "auto")
INSTALL_MODES = ("all", "claude", "codex", "cursor")


def asset_root() -> Path:
    return Path(str(files("pact_toolkit").joinpath("assets")))


def detect_mode(target: Path) -> str:
    has_claude = (target / ".claude").exists() or (target / "CLAUDE.md").exists()
    has_codex = (target / "AGENTS.md").exists()
    has_cursor = (target / ".cursor").exists()

    matches = [has_claude, has_codex, has_cursor]
    if sum(matches) > 1:
        return "all"
    if has_claude:
        return "claude"
    if has_cursor:
        return "cursor"
    if has_codex:
        return "codex"
    return "all"


def mode_items(mode: str) -> list[tuple[str, str]]:
    if mode == "all":
        return [
            ("CLAUDE.md", "CLAUDE.md"),
            ("claude", ".claude"),
            ("pact", ".pact"),
            ("AGENTS.md", "AGENTS.md"),
            ("cursor", ".cursor"),
        ]
    if mode == "claude":
        return [("CLAUDE.md", "CLAUDE.md"), ("claude", ".claude"), ("pact", ".pact")]
    if mode == "codex":
        return [("AGENTS.md", "AGENTS.md"), ("pact", ".pact")]
    if mode == "cursor":
        return [("cursor", ".cursor"), ("AGENTS.md", "AGENTS.md"), ("pact", ".pact")]
    raise ValueError(f"invalid mode: {mode}")


def copy_item(src: Path, dst: Path, force: bool) -> None:
    if not src.exists():
        raise SystemExit(f"Missing packaged asset: {src}")

    if dst.exists():
        if not force:
            raise SystemExit(f"Refusing to overwrite existing path: {dst}. Use --force.")
        if dst.is_dir():
            shutil.rmtree(dst)
        else:
            dst.unlink()

    dst.parent.mkdir(parents=True, exist_ok=True)
    if src.is_dir():
        shutil.copytree(src, dst)
    else:
        shutil.copy2(src, dst)


def install(args: argparse.Namespace) -> int:
    root = asset_root()
    target = Path(args.target).expanduser().resolve()
    target.mkdir(parents=True, exist_ok=True)
    mode = detect_mode(target) if args.mode == "auto" else args.mode

    for src_name, dst_name in mode_items(mode):
        copy_item(root / src_name, target / dst_name, args.force)

    print("PACT installed.")
    print()
    print(f"Target: {target}")
    print(f"Mode:   {mode}")
    if args.mode == "auto":
        print("Auto:   selected from existing project files")
    print()
    print("Next:")
    print("- Claude Code: run /pact.init, then /pact.scope before the first feature.")
    print("- Codex/Cursor: ask the agent to initialize the project using PACT.")
    print("- Self-check in installed projects: pact check --project")
    return 0


def doctor(args: argparse.Namespace) -> int:
    cwd = Path(args.cwd).expanduser().resolve()
    checks = [
        ("python", f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}", sys.version_info >= (3, 9)),
        ("bash", shutil.which("bash") or "not found", shutil.which("bash") is not None),
        ("git", shutil.which("git") or "not found", shutil.which("git") is not None),
        ("pact files", ".pact found" if (cwd / ".pact").exists() else ".pact not found", (cwd / ".pact").exists()),
        ("Claude adapter", "found" if ((cwd / ".claude").exists() or (cwd / "CLAUDE.md").exists()) else "not found", True),
        ("Codex adapter", "found" if (cwd / "AGENTS.md").exists() else "not found", True),
        ("Cursor adapter", "found" if (cwd / ".cursor").exists() else "not found", True),
    ]

    print("PACT environment report")
    print()
    print(f"Project: {cwd}")
    print(f"Suggested install mode: {detect_mode(cwd)}")
    print()
    for name, value, ok in checks:
        mark = "OK" if ok else "WARN"
        print(f"[{mark}] {name}: {value}")
    print()
    print("Install:")
    print("  pact install --target . --mode auto")
    print("Check:")
    print("  pact check --project")

    required_ok = sys.version_info >= (3, 9) and shutil.which("bash") is not None
    return 0 if required_ok else 1


def run_pact_script(args: argparse.Namespace, command_args: list[str]) -> int:
    cwd = Path(args.cwd).expanduser().resolve()
    script = cwd / ".pact" / "bin" / "pact.sh"
    if not script.exists():
        raise SystemExit(f"PACT wrapper not found: {script}. Install PACT into this project first.")
    if shutil.which("bash") is None:
        raise SystemExit("PACT checks require bash. Install Git Bash, WSL, or another bash-compatible shell.")

    cmd = ["bash", ".pact/bin/pact.sh", *command_args]
    return subprocess.call(cmd, cwd=str(cwd))


def check(args: argparse.Namespace) -> int:
    if args.repo and args.project:
        raise SystemExit("Choose either --repo or --project, not both.")
    return run_pact_script(args, ["check", "--repo" if args.repo else "--project"])


def guard(args: argparse.Namespace) -> int:
    if args.fixtures:
        return run_pact_script(args, ["guard", "--fixtures"])
    if not args.stage:
        raise SystemExit("guard requires a stage: pid, contract, build, verify, or ship.")
    return run_pact_script(args, ["guard", args.stage])


def lint_contract(args: argparse.Namespace) -> int:
    selected = [bool(args.all), bool(args.fixtures), bool(args.target)]
    if sum(selected) != 1:
        raise SystemExit("lint-contract requires exactly one of: target, --all, or --fixtures.")
    target = "--all" if args.all else "--fixtures" if args.fixtures else args.target
    return run_pact_script(args, ["lint-contract", target])


def lint_verify(args: argparse.Namespace) -> int:
    selected = [bool(args.all), bool(args.fixtures), bool(args.target)]
    if sum(selected) != 1:
        raise SystemExit("lint-verify requires exactly one of: target, --all, or --fixtures.")
    target = "--all" if args.all else "--fixtures" if args.fixtures else args.target
    return run_pact_script(args, ["lint-verify", target])


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="pact", description="PACT Toolkit CLI")
    sub = parser.add_subparsers(dest="command", required=True)

    p_install = sub.add_parser("install", help="Install PACT files into a project")
    p_install.add_argument("--target", "-t", default=".", help="Target project directory")
    p_install.add_argument("--mode", "-m", choices=VALID_MODES, default="all", help="Install mode")
    p_install.add_argument("--force", action="store_true", help="Overwrite existing PACT files")
    p_install.set_defaults(func=install)

    p_doctor = sub.add_parser("doctor", help="Detect local PACT environment")
    p_doctor.add_argument("--cwd", default=".", help="Project directory")
    p_doctor.set_defaults(func=doctor)

    p_check = sub.add_parser("check", help="Run PACT checks")
    p_check.add_argument("--repo", action="store_true", help="Run framework repository checks")
    p_check.add_argument("--project", action="store_true", help="Run installed project checks")
    p_check.add_argument("--cwd", default=".", help="Project directory")
    p_check.set_defaults(func=check)

    p_guard = sub.add_parser("guard", help="Run a PACT guard")
    p_guard.add_argument("stage", nargs="?", choices=("pid", "contract", "build", "verify", "ship", "fixtures"))
    p_guard.add_argument("--fixtures", action="store_true", help="Run guard fixtures")
    p_guard.add_argument("--cwd", default=".", help="Project directory")
    p_guard.set_defaults(func=guard)

    p_lint_contract = sub.add_parser("lint-contract", help="Lint a PACT contract")
    p_lint_contract.add_argument("target", nargs="?", help="Contract file")
    p_lint_contract.add_argument("--all", action="store_true", help="Lint all contracts")
    p_lint_contract.add_argument("--fixtures", action="store_true", help="Run contract lint fixtures")
    p_lint_contract.add_argument("--cwd", default=".", help="Project directory")
    p_lint_contract.set_defaults(func=lint_contract)

    p_lint_verify = sub.add_parser("lint-verify", help="Lint a PACT verify record")
    p_lint_verify.add_argument("target", nargs="?", help="Verify file")
    p_lint_verify.add_argument("--all", action="store_true", help="Lint all verify records")
    p_lint_verify.add_argument("--fixtures", action="store_true", help="Run verify lint fixtures")
    p_lint_verify.add_argument("--cwd", default=".", help="Project directory")
    p_lint_verify.set_defaults(func=lint_verify)

    p_release = sub.add_parser("release-check", help="Run optional git-aware release check")
    p_release.add_argument("--cwd", default=".", help="Project directory")
    p_release.set_defaults(func=lambda a: run_pact_script(a, ["release-check"]))

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    return int(args.func(args))


if __name__ == "__main__":
    sys.exit(main())
