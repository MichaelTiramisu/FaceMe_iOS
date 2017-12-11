//
//  MainViewController.m
//  FaceMe
//
//  Created by SiyangLiu on 2017/12/10.
//  Copyright © 2017年 SiyangLiu. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *categoryNames;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.categoryNames = @[@"Photo", @"Video", @"VideoAndAudio"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.categoryNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CategoryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    [cell.textLabel setText:self.categoryNames[indexPath.row]];
    return cell;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    if (row == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Photo" bundle:nil];
        UIViewController *vc = [storyboard instantiateInitialViewController];
        [[self navigationController] pushViewController:vc animated:YES];
    } else if (row == 1) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Video" bundle:nil];
        UIViewController *vc = [storyboard instantiateInitialViewController];
        [[self navigationController] pushViewController:vc animated:YES];
    } else if (row == 2) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"VideoAndAudio" bundle:nil];
        UIViewController *vc = [storyboard instantiateInitialViewController];
        [[self navigationController] pushViewController:vc animated:YES];
    }
}

@end
