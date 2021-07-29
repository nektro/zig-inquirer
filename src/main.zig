const std = @import("std");
const inquirer = @import("inquirer");

// Comparison adaptation of https://github.com/SBoudrias/Inquirer.js/blob/master/packages/inquirer/examples/pizza.js

pub fn main() !void {
    std.log.info("All your codebase are belong to us.", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = &gpa.allocator;

    _ = try inquirer.forConfirm("Is this for delivery?", alloc);

    _ = try inquirer.forString("What's your phone number?", alloc, null);

    _ = try inquirer.forEnum("What size do you need?", alloc, enum { Small, Medium, Large }, null);

    // _ = try inquirer.forNumber("How many do you need?", alloc, u32, 1);
    // TODO forNumber is causing a compiler crash

    // TODO toppings for string list

    _ = try inquirer.forEnum("You also get a free 2L:", alloc, enum { Pepsi, @"7up", Coke }, null);

    const comment = try inquirer.forString("Any comments on your purchase experience?", alloc, "Nope, all good!");

    if (std.mem.eql(u8, comment, "")) {
        _ = try inquirer.forEnum("For leaving a comment, you get a freebie:", alloc, enum { Cake, Fries }, null);
    }
}
