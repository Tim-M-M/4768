//
//  ViewController.m
//  viewSwapping
//
//  Created by Gabriel A Lau on 2016-03-27.
//  Copyright © 2016 Gabriel A Lau. All rights reserved.
//

#import "MonsterViewController.h"
#import "MonsterAnimate.h"

@interface MonsterViewController()
@property (weak, nonatomic) IBOutlet SKView *viewArea;


@end
@implementation MonsterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromRGB(0x009ECE);
    // Do any additional setup after loading the view, typically from a nib.
    // Configure the view.
    SKView * skView = (SKView *) self.viewArea;
    
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [MonsterAnimate sceneWithSize:self.view.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    // Present the scene.
    [skView presentScene:scene];
   
}
- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(reportScore:)
     name:@"doneAnime"
     object:nil];
     NSLog(@"awakefromnib");
}

-(void)reportScore:(NSNotification *) notification {
    NSLog(@"notification call");
    [self performSegueWithIdentifier:@"goBack" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
