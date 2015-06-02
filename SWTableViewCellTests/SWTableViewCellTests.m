#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <FBSnapshotTestCase/FBSnapshotTestCase.h>
#import <Expecta+Snapshots/EXPMatchers+FBSnapshotTest.h>
#import <OCMock/OCMock.h>
#import "SWTableViewCell.h"

SpecBegin(SWTableViewCell)

__block NSArray *rightButtons;
__block NSArray *leftButtons;

before(^{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                title:@"More"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];

    rightButtons = rightUtilityButtons;
    
    
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0]
                                                icon:[UIImage imageNamed:@"check.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:1.0]
                                                icon:[UIImage imageNamed:@"clock.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0]
                                                icon:[UIImage imageNamed:@"cross.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.55f green:0.27f blue:0.07f alpha:1.0]
                                                icon:[UIImage imageNamed:@"list.png"]];
    
    leftButtons = leftUtilityButtons;
    
});

describe(@"init", ^{
    it(@"should init with cell style UITableViewStyleDefault", ^{
        SWTableViewCell *cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        expect(cell).toNot.beNil;
    });
    
    it(@"should init with cell style UITableViewStyleSubtitle", ^{
        SWTableViewCell *cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        expect(cell).toNot.beNil;
    });
});

describe(@"buttons", ^{
    __block SWTableViewCell *cell;
    
    before(^{
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [cell setRightUtilityButtons:rightButtons WithButtonWidth:44.0f];
        [cell setLeftUtilityButtons:leftButtons WithButtonWidth:44.0f];
    });

    it(@"should have two right buttons", ^{
        expect(cell.rightUtilityButtons.count).to.equal(2);
    });
    
    it(@"should have four left buttons", ^{
        expect(cell.leftUtilityButtons.count).to.equal(4);
    });
});


SpecEnd