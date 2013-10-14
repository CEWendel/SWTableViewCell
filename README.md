SWTableViewCell
===============

<p align="center"><img src="http://i.imgur.com/njKCjK8.gif"/></p>

An easy-to-use UITableViewCell subclass that implements a swippable content view which exposes utility buttons (similar to iOS 7 Mail Application)

##Functionality
###Right Utility Buttons
Utility buttons that become visible on the right side of the Table View Cell when the user swipes left. This behavior is similar to that seen in the iOS apps Mail and Reminders.

<p align="center"><img src="http://i.imgur.com/gDZFRpr.gif"/></p>

###Left Utility Buttons
Utility buttons that become visible on the left side of the Table View Cell when the user swipes right. 

<p align="center"><img src="http://i.imgur.com/qt6aISz.gif"/></p>

###Features
* Dynamic utility button scalling. As you add more buttons to a cell, the other buttons on that side get smaller to make room
* Smart selection: The cell will pick up touch events and either scroll the cell back to center or fire the delegate method `- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath` 
<p align="center"><img src="http://i.imgur.com/TYGx9h8.gif"/></p>
So the cell will not be considered selected when the user touches the cell while utility buttons are visible, instead the cell will slide back into place (same as iOS 7 Mail App functionality)
* Create utilty buttons with either a title or an icon along with a RGB color
* Tested on iOS 6.1 and above, including iOS 7

##Usage

In your `tableView:cellForRowAtIndexPath:` method you set up the SWTableView cell and add an arbitrary amount of utility buttons to it using the included `NSMutableArray+SWUtilityButtons` category.

```objc
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSMutableArray *leftUtilityButtons = [NSMutableArray new];
        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
        
        [leftUtilityButtons addUtilityButtonWithColor:
                        [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0] 
                        icon:[UIImage imageNamed:@"check.png"]];
        [leftUtilityButtons addUtilityButtonWithColor:
                        [UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:1.0] 
                        icon:[UIImage imageNamed:@"clock.png"]];
        [leftUtilityButtons addUtilityButtonWithColor:
                        [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0] 
                        icon:[UIImage imageNamed:@"cross.png"]];
        [leftUtilityButtons addUtilityButtonWithColor:
                        [UIColor colorWithRed:0.55f green:0.27f blue:0.07f alpha:1.0] 
                        icon:[UIImage imageNamed:@"list.png"]];
        
        [rightUtilityButtons addUtilityButtonWithColor:
                        [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                        title:@"More"];
        [rightUtilityButtons addUtilityButtonWithColor:
                        [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f] 
                            title:@"Delete"];
        
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                        reuseIdentifier:cellIdentifier 
                        containingTableView:_tableView // For row height and selection
                        leftUtilityButtons:leftUtilityButtons 
                        rightUtilityButtons:rightUtilityButtons];
        cell.delegate = self;
    }
    
    NSDate *dateObject = _testArray[indexPath.row];
    cell.textLabel.text = [dateObject description];
    cell.detailTextLabel.text = @"Some detail text";

return cell;
}
```

###Delegate

The delegate `SWTableViewCellDelegate` is used by the developer to find out which button was pressed. There are two methods:

```objc
- (void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index;
- (void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index;
```

The index signifies which utility button the user pressed, for each side the button indices are ordered from right to left 0...n

####Example

```objc
#pragma mark - SWTableViewDelegate

- (void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
            NSLog(@"check button was pressed");
            break;
        case 1:
            NSLog(@"clock button was pressed");
            break;
        case 2:
            NSLog(@"cross button was pressed");
            break;
        case 3:
            NSLog(@"list button was pressed");
        default:
            break;
    }
}

- (void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
            NSLog(@"More button was pressed");
            break;
        case 1:
        {
            // Delete button was pressed
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            
            [_testArray removeObjectAtIndex:cellIndexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] 
                    withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        default:
            break;
    }
}
```

(This is all code from the included example project)

###Gotchas

#### Custom `UITableViewCell` content
* Don't use Storyboards to create your custom `UITableViewCell` content. Simply add views to the cell's `contentView` in `- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath`
* Accessing view of the cell object or managing the predefined content still works fine. So for example if you change the cell's `imageView` or `backgroundView`, `SWTableViewCell` will still work as expected
* Don't use accessory views in your cell, because they live above the `contentView` and will stay in place when the cell scrolls.

#### Seperator Insets
* If you have left utility button on iOS 7, I recommend changing your Table View's seperatorInset so the seperator stretches the length of the screen
<pre> tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0); </pre>


##Contributing
Use [Github issues](https://github.com/cewendel/SWTableViewCell/issues) to track bugs and feature requests.


##Contact

Chris Wendel

- http://twitter.com/CEWendel

## Licence

MIT 





