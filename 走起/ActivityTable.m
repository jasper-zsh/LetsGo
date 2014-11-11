//
//  ActivityTable.m
//  LetsGo
//
//  Created by 周瑞琦 on 11/5/14.
//
//

#import "ActivityTable.h"

@interface ActivityTable ()

@end

@implementation ActivityTable

- (void)viewDidLoad {
    [self preinit];
    [super viewDidLoad];
    [self initRefreshControl];
    [self.refreshControl beginRefreshing];
    [self RefreshATable];
}

-(void)preinit{
    //[[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0/255.0 green:150/255.0 blue:136/255.0 alpha:1]];
    //[self.navigationController.navigationBar setTranslucent:NO];
    Mytoken=@"46Ms7ERFe7dpzXCFKjyw";//////////////////////////!!!!!!!!!!!!**************************************!!!!!!!!!!!!!
    NSLog(@"ActivityTable Get Aid=%@",self.Aid);
    SendCommentBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    ContentTxT=[[UITextView alloc]initWithFrame:CGRectMake(0, 40.0f, [UIScreen mainScreen].applicationFrame.size.width, CGFLOAT_MAX)];
    ContentTxT.editable=NO;
    ContentTxT.scrollEnabled=NO;
    ContentTxT.textColor=[UIColor colorWithRed:96.0/255 green:125.0/255 blue:139.0/255 alpha:1.0f];
    
    ContentTitle=[[UILabel alloc]initWithFrame:CGRectMake(8.0f, 8.0f, 80.0f, 30.0f)];
    ContentTitle.font=[UIFont systemFontOfSize:18.0f];
    ContentTitle.text=@"活动详情";
    ContentTitle.textColor=[UIColor colorWithRed:96.0/255 green:125.0/255 blue:139.0/255 alpha:1.0f];
}
-(void)CellPrepare{
    
    ContentTxT.text=[AData_Dic objectForKey:@"activity_content"];
    [ContentTxT sizeToFit];
    ContentH=ContentTxT.frame.size.height;
    
    ImgURL=[NSData dataWithContentsOfURL:[NSURL URLWithString:[AData_Dic objectForKey:@"activity_pic"]]];
    TitleTxt=[AData_Dic objectForKey:@"activity_title"];
    OwnerTxt=[NSString stringWithFormat:@"发起者：%@",[AData_Dic objectForKey:@"owner_name"]];
    OrginizationTxt=[NSString stringWithFormat:@"活动所属群组：%@",[AData_Dic objectForKey:@"organization_name"]];
    PlaceTxt=[NSString stringWithFormat:@"活动地点：%@",[AData_Dic objectForKey:@"activity_place"]];
    TimeTxt=[NSString stringWithFormat:@"%@ - %@",[AData_Dic objectForKey:@"activity_begin_time"],[AData_Dic objectForKey:@"activity_end_time"]];
    PeopleTxt=[NSString stringWithFormat:@"报名人数：%@   人数限额：%@",[AData_Dic objectForKey:@"activity_people_max"],[AData_Dic objectForKey:@"activity_people_number"]];
    
    [SendCommentBtn setTitle:@"发表评论" forState:UIControlStateNormal];
    SendCommentBtn.titleLabel.font=[UIFont systemFontOfSize: 13.0];
    SendCommentBtn.backgroundColor=[UIColor blackColor];
    [SendCommentBtn addTarget:self action:@selector(OpenSendCommentBtn) forControlEvents:UIControlEventTouchDown];
    Afinished=[[AData_Dic objectForKey:@"finished"]boolValue];
    Ajioned=[[AData_Dic objectForKey:@"jioned"]boolValue];
}

-(void) initRefreshControl{
    UIRefreshControl *Rc=[[UIRefreshControl alloc]init];
    Rc.attributedTitle=[[NSAttributedString alloc]initWithString:@"👻下拉刷新"];
    [Rc addTarget:self action:@selector(RefreshATable) forControlEvents:UIControlEventValueChanged];
    self.refreshControl=Rc;
}

-(void) RefreshATable{
    if(self.refreshControl.refreshing){
        self.refreshControl.attributedTitle=[[NSAttributedString alloc]initWithString:@"😂加载中"];
        [self GetActivityDetail];
    }
}

-(void)GetActivityDetail{
    AData=[NSMutableData alloc];
    NSString *URLplist=[[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    NSString *URLpre=[[[NSDictionary alloc]initWithContentsOfFile:URLplist] objectForKey:@"URLprefix"];
    [[GetInfo alloc]initWithURL:[NSString stringWithFormat:@"%@/activities/%@.json?user_token=%@",URLpre,self.Aid,Mytoken] ResultData:AData sender:self OnSuccess:@selector(ProcessData) OnError:@selector(DealError)];
}

-(void) ProcessData{
    if(self.refreshControl.refreshing)
    {
        [self.refreshControl endRefreshing];
        self.refreshControl.attributedTitle=[[NSAttributedString alloc]initWithString:@"👻下拉刷新"];
    }
    NSLog(@"Json Success received!!!");
    AData_Dic= [NSJSONSerialization JSONObjectWithData:AData options:NSJSONReadingMutableContainers error:nil];
    AComment=[AData_Dic objectForKey:@"comments"];
    [self CellPrepare];
    [self.ATableView reloadData];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [segue.destinationViewController setValue:[AData_Dic objectForKey:@"comments"] forKey:@"CommentList"];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==0)
        return 4;
    else
        return AComment.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (UITableViewCell *) tableView:(UITableView *)tableView
          cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section]==0)
    {
        switch([indexPath row])
        {
            case 0:{
                ImgAndTitleCellLoaded=NO;
                if(!ImgAndTitleCellLoaded){
                    NSLog(@"Conetent cell is nil,Creat Content Cell");
                    UINib *nib=[UINib nibWithNibName:@"ActivityImgTitleCell" bundle:nil];
                    [tableView registerNib:nib forCellReuseIdentifier:@"AITC"];
                    ImgAndTitleCellLoaded=YES;
                }
                ActivityImgTitleCell *cell=[tableView dequeueReusableCellWithIdentifier:@"AITC"];
                if(cell==nil)
                {
                    cell=[[ActivityImgTitleCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AITC"];
                }
                cell.ActivityImg.image=[UIImage imageWithData:ImgURL];
                cell.accessoryType=UITableViewCellAccessoryNone;
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                [cell initWithImg:ImgURL Title:TitleTxt Place:PlaceTxt Time:TimeTxt Owner:OwnerTxt];
                return cell;
            }
                break;
            case 1:
            {
                UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"ContentT"];
                if(cell==nil)
                {
                    NSLog(@"Conetent Title cell is nil,Creat Content Title Cell");
                    cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ContentT"];
                }
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                [cell addSubview:ContentTitle];
                return cell;
            }
            case 2:
            {
                UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"ContentCell"];
                if(cell==nil)
                {
                    NSLog(@"Conetent cell is nil,Creat Content Cell");
                    cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ContentCell"];
                }
                [cell addSubview:ContentTxT];
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                return cell;
            }
                break;
            case 3:
            {
                UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"BtnCell"];
                if(cell==nil)
                    cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BtnCell"];
                if(Afinished)
                {
                    ButtonStyle=0;
                    cell.textLabel.text=@"发表评论";
                }
                else
                {
                    if(Ajioned)
                    {
                        ButtonStyle=1;
                        cell.textLabel.text=@"离开";
                    }
                    else
                    {
                        ButtonStyle=2;
                        cell.textLabel.text=@"加入";
                    }
                }
                cell.textLabel.font=[UIFont systemFontOfSize:18.0f];
                cell.textLabel.textColor=[UIColor whiteColor];
                cell.textLabel.textAlignment=NSTextAlignmentCenter;
                cell.backgroundColor=[UIColor colorWithRed:38.0/255 green:166.0/255 blue:154.0/255 alpha:1.0];
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                return cell;
            }
                break;
            default:
            {
                UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"aaaa"];
                if(cell==nil)
                {
                    cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"aaaa"];
                }
                cell.textLabel.text=@"testtttt";
                //cell.selectionStyle=UITableViewCellSelectionStyleNone;
                return cell;
            }
        }
    }
    else
    {
        static BOOL CommentCellLoaded=NO;
        if(!CommentCellLoaded){
            UINib *nib=[UINib nibWithNibName:@"CommentCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:@"CC"];
            CommentCellLoaded=YES;
        }
        CommentCell *cell=[tableView dequeueReusableCellWithIdentifier:@"CC"];
        if (cell==nil ) {
            cell=[[CommentCell alloc ] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CC"];
        }
        NSDictionary *tmp =[AComment objectAtIndex:[indexPath row]];
        cell.User_name.text=[tmp objectForKey:@"email"];
        cell.CommentContent.text=[tmp objectForKey:@"comment_content"];
        if([[AComment objectAtIndex:[indexPath row]] objectForKey:@"user_logo"])
        {
            cell.UserLogo.image=[UIImage imageNamed:@"SnowPng"];
        }
        else
        {
            cell.UserLogo.image=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[AComment objectAtIndex:[indexPath row]]objectForKey:@"user_logo"]]]];
        }
        cell.accessoryType=UITableViewCellAccessoryNone;
        return cell;
        
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([indexPath section]==0)
    {
        switch ([indexPath row]) {
            case 0://IMG TITLE
                return 154;
                break;
            case 1:
                return 46;
            case 2:
                return ContentH;
                break;
            default:
                return 40;
                break;
        }
    }
    else
    {
        return 70;
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section==0)
    {
        UIView *cell=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, 1)];
        return cell;
    }
    else
    {
        UIView *CTview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, 15)];
        UILabel *CTL=[[UILabel alloc]initWithFrame:CGRectMake(8, 8, [UIScreen mainScreen].applicationFrame.size.width, 15)];
        CTL.text=[NSString stringWithFormat: @"评论 %d",AComment.count];
        CTL.font=[UIFont systemFontOfSize:13.0f];
        CTL.textColor=[UIColor colorWithRed:96.0/255 green:125.0/255 blue:139.0/255 alpha:1.0f];
        CTview.backgroundColor=[UIColor whiteColor];
        [CTview addSubview:CTL];
        return CTview;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([indexPath row]==3)
    {
        switch(ButtonStyle)
        {
            case 0:
            {
                NSLog(@"Press SendComment Button");
                [self OpenSendCommentBtn];
            }
                break;
            case 1:
            {
                NSLog(@"Press Quit Activity Button");
            }
                break;
            case 2:
            {
                [self JionActivity];
                NSLog(@"Press Jion Activity Button");
            }
                break;
            default:
                NSLog(@"Press Button Error!!");
        }
    }
}


-(void)QuitActivity{
    //curl -X DELETE -H "Content-Type: application/json" -d '{"activity_id":1}' localhost:3000/activity_memberships.json?user_token=dB4EyczCNnaGayypEZXG
    
    NSString *URLplist=[[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    NSString *URLpre=[[[NSDictionary alloc]initWithContentsOfFile:URLplist] objectForKey:@"URLprefix"];
    NSString *CompleteURL=[NSString stringWithFormat:@"%@/activity_memberships.json?user_token=%@",URLpre,Mytoken];
    NSDictionary *PrepareToJsonDic=[[NSDictionary alloc]initWithObjectsAndKeys:@"activity_id",[self.Aid integerValue], nil];
    NSData *PostDataInfo=[NSJSONSerialization dataWithJSONObject:PrepareToJsonDic options:NSJSONWritingPrettyPrinted error:nil];
    [[PostInfo alloc]initWithURL:CompleteURL HttpMethod:@"DELETE" postData:PostDataInfo resultData:PostReslut sender:self onSuccess:@selector(QuitSuccess) onError:nil];
}

-(void)JionActivity{
    //curl -X POST -H "Content-Type: application/json" -d  localhost:3000/activity_memberships.json?user_token=dB4EyczCNnaGayypEZXG
    NSLog(@"Do Jion Activity Request");
    NSString *URLplist=[[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    NSString *URLpre=[[[NSDictionary alloc]initWithContentsOfFile:URLplist] objectForKey:@"URLprefix"];
    NSString *CompleteURL=[NSString stringWithFormat:@"%@/activity_memberships.json?user_token=%@",URLpre,Mytoken];
    //NSDictionary *PrepareToJsonDic=[[NSDictionary alloc]initWithObjectsAndKeys:@"activity_id",[NSNumber numberWithInt:[self.Aid integerValue]], nil];
    NSData *JoinData=[[NSString stringWithFormat:@"{\"activity_id\":%d}",[self.Aid integerValue]] dataUsingEncoding:NSUTF8StringEncoding];
    //NSLog(@"URL=%@,DATA=%@",CompleteURL,[[NSString alloc]initWithData:JoinData encoding:NSUTF8StringEncoding] );
    [[PostInfo alloc]initWithURL:CompleteURL HttpMethod:@"POST" postData:JoinData resultData:PostReslut sender:self onSuccess:@selector(JionSuccess) onError:nil];
}

-(void)JionSuccess
{
    NSLog(@"Jion Activity Success,Receive: %@",[[NSString alloc]initWithData:PostReslut encoding:NSUTF8StringEncoding]);
}

-(void)QuitSuccess
{
    NSLog(@"Quit Success");
}


-(void)OpenSendCommentBtn{
    UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SendCommentViewController *SendCommentVC=[storyBoard instantiateViewControllerWithIdentifier:@"SendCommentView" ];
    [self presentViewController:SendCommentVC animated:YES completion:^{
    }];
    
}


-(void)DealError{
    NSLog(@"NetWork Error");
    MBProgressHUD *ErrorView=[[MBProgressHUD alloc]initWithView:self.view];
    ErrorView.customView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Cry"]];
    ErrorView.mode=MBProgressHUDModeCustomView;
    ErrorView.delegate=self;
    [self.view addSubview:ErrorView];
    ErrorView.labelText=@"网络不给力";
    [ErrorView show:YES];
    [ErrorView hide:YES afterDelay:2];
    if(self.refreshControl.refreshing)
    {
        [self.refreshControl endRefreshing];
        self.refreshControl.attributedTitle=[[NSAttributedString alloc]initWithString:@"👻下拉刷新"];
    }
    
}
-(void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
    hud = nil;
}



@end
