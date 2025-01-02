const std = @import("std");
const inquirer = @import("inquirer");

test {
    // ensure these have no compile errors
    // but don't write anything to stdout/stderr
    _ = &inquirer.answer;
    _ = &inquirer.forEnum;
    _ = &inquirer.forString;
    _ = &inquirer.forConfirm;
}
