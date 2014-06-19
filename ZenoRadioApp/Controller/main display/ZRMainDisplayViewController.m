//
//  ZRMainDisplayViewController.m
//  ZenoRadioApp
//
//  Created by Atamosa Antonio Jr. on 6/16/14.
//  Copyright (c) 2014 ICONS. All rights reserved.
//
#include <stdio.h>

#include <pjsua-lib/pjsua.h>
#define THIS_FILE	"APP"


#import "ZRMainDisplayViewController.h"
#import "ZRSpeakerVolume.h"
static pjsua_acc_id acc_id = PJSUA_INVALID_ID;      //ACCOUNT ID
static pjsua_call_id cid;                           //CALL ID

@interface ZRMainDisplayViewController ()
{
    NSTimer *tmrHeadsetArrowAnimation;
    NSTimer *tmrCallArrowAnimation;
    int greenArrowCounter;
    int redArrowCounter;
    BOOL isListening;
    BOOL isCalling;
    BOOL isPaused;
    BOOL isFromSuccessfulDrag;
    float appVolume;
    BOOL isCallPopShown;
}
@property (nonatomic,strong) IBOutlet ZRSpeakerVolume *speakerVolume;
@property (nonatomic,strong) IBOutlet UIView *vwChargePopUp;
@property (nonatomic,strong) IBOutlet UIImageView *imgInfo;
//HEADSER
@property (nonatomic,strong) IBOutlet UIView *vwHeadsetContainer;
@property (nonatomic,strong) IBOutlet UIView *vwHeadSetNormal;
@property (nonatomic,strong) IBOutlet UIView *vwHeadSetCollapse;
@property (nonatomic,strong) IBOutlet UIButton *btnHeadset;
@property (nonatomic,strong) IBOutlet UIView *vwHeadset;
@property (nonatomic,strong) IBOutlet UISlider *sldrHeadset;
@property (nonatomic,strong) IBOutlet UIImageView *imgGreenArrow1;
@property (nonatomic,strong) IBOutlet UIImageView *imgGreenArrow2;
@property (nonatomic,strong) IBOutlet UIImageView *imgSlideHeaderCover;

//CALL
@property (nonatomic,strong) IBOutlet UIView *vwCallContainer;
@property (nonatomic,strong) IBOutlet UIView *vwCallNormal;
@property (nonatomic,strong) IBOutlet UIView *vwCallCollapse;
@property (nonatomic,strong) IBOutlet UIButton *btnCall;
@property (nonatomic,strong) IBOutlet UIView *vwCall;
@property (nonatomic,strong) IBOutlet UISlider *sldrCall;
@property (nonatomic,strong) IBOutlet UIImageView *imgRedArrow1;
@property (nonatomic,strong) IBOutlet UIImageView *imgRedArrow2;
@property (nonatomic,strong) IBOutlet UIImageView *imgSlideCallCover;

@end

@implementation ZRMainDisplayViewController
 uint aCID;

///////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark SIP code
///////////////////////////////////////////////////////////////////////////////////////////////////////
void pjsip_hangup()
{
	if (acc_id!=PJSUA_INVALID_ID) {
		pjsua_msg_data msg_data;
		
		pjsua_msg_data_init(&msg_data);
		
		pjsua_call_hangup  (cid, 200, 0, 0);
		
	}
	
}

static void error_exit(const char *title, pj_status_t status)
{
    pjsua_perror(THIS_FILE, title, status);
    pjsua_destroy();
    //exit(1);
}

int pjsip_regist_account(char* sip_user, char* sip_passwd, char* sip_domain, char* sip_realm)
{
    /* Register to SIP server by creating SIP account. */
	pjsua_acc_config cfg;
	
	pjsua_acc_config_default(&cfg);
	
	char string_id[1024];
	char string_reg_uri[1024];
	
	sprintf(string_id, "sip:%s@%s", sip_user, sip_domain);
	cfg.id = pj_str(string_id);
	sprintf(string_reg_uri, "sip:%s", sip_domain);
	cfg.reg_uri = pj_str(string_reg_uri);
	cfg.cred_count = 1;
	cfg.cred_info[0].realm = pj_str(sip_realm);
	cfg.cred_info[0].scheme = pj_str("digest");
	cfg.cred_info[0].username = pj_str(sip_user);
	cfg.cred_info[0].data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
	cfg.cred_info[0].data = pj_str(sip_passwd);
	
    pj_status_t status;
	status = pjsua_acc_add(&cfg, PJ_TRUE, &acc_id);
	if (status != PJ_SUCCESS)
	{
		error_exit("Error adding account", status);
		return 0;
    }
	
	return 1;
}
static void on_call_media_state(pjsua_call_id call_id)
{
    pjsua_call_info ci;
	
    pjsua_call_get_info(call_id, &ci);
    
    if (ci.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
		// When media is active, connect call to sound device.
		pjsua_conf_connect(ci.conf_slot, 0);
		pjsua_conf_connect(0, ci.conf_slot);
    }
}

static void on_call_state(pjsua_call_id call_id, pjsip_event *e)
{
    pjsua_call_info ci;
	
    PJ_UNUSED_ARG(e);
	
    pjsua_call_get_info(call_id, &ci);
    PJ_LOG(3,(THIS_FILE, "Call %d state=%.*s", call_id,
			  (int)ci.state_text.slen,
			  ci.state_text.ptr));
}

void setcall_id(uint i){
	aCID = i;
}


static void on_incoming_call(pjsua_acc_id acc_id, pjsua_call_id call_id,
							 pjsip_rx_data *rdata)
{
    
    pjsua_call_info ci;
	
    PJ_UNUSED_ARG(acc_id);
    PJ_UNUSED_ARG(rdata);
	
    pjsua_call_get_info(call_id, &ci);
	//char *c;
	//sprintf(c,"%s",ci.remote_info.ptr);
	//printf("%s",ci.remote_info.ptr);
    PJ_LOG(3,(THIS_FILE, "Incoming call from %.*s!!",
			  (int)ci.remote_info.slen,
			  ci.remote_info.ptr));
	
    /* Automatically answer incoming calls with 200/OK */
    pjsua_call_answer(call_id, 200, NULL, NULL);
	//[Button setTitle:@"Hangup" forState:UIControlStateNormal];
}



int pjsip_make_call(char* sip_url)
{
    /* If argument is specified, it's got to be a valid SIP URL */
    pj_status_t status = pjsua_verify_sip_url(sip_url);
	if (status != PJ_SUCCESS)
	{
		error_exit("Invalid call URL", status);
		return 0;
	}
	
    /* If URL is specified, make call to the URL. */
	pj_str_t uri = pj_str(sip_url);
    printf("\n\nacc_id=%d\n\n",acc_id);
	status = pjsua_call_make_call(acc_id, &uri, 0, NULL, NULL, &cid);
	pjsua_call_info ci;
    pjsua_call_get_info(cid, &ci);
    //acc_id = cid;
	setcall_id(cid);
	if (status != PJ_SUCCESS)
	{
		error_exit("Error making call", status);
		return 0;
    }
	
	return 1;
}

int pjsip_init(const char*stun_server, const char *logfile)
{
    pj_status_t status;
	
    /* Create pjsua first! */
    status = pjsua_create();
    if (status != PJ_SUCCESS)
	{
		error_exit("Error in pjsua_create()", status);
		return 0;
	}
	
    /* Init pjsua */
    {
		pjsua_config cfg;
		pjsua_logging_config log_cfg;
		
		pjsua_config_default(&cfg);
		cfg.cb.on_incoming_call = &on_incoming_call;
		cfg.cb.on_call_media_state = &on_call_media_state;
		cfg.cb.on_call_state = &on_call_state;
		if (stun_server && stun_server[0]) {
            char *sStun_server = (char *)stun_server;
			cfg.stun_host =  pj_str(sStun_server);
		}
		pjsua_logging_config_default(&log_cfg);
		log_cfg.console_level = 5;
		log_cfg.level = 4;
        char *sLogfile = (char *)logfile;
		log_cfg.log_filename = pj_str(sLogfile);
		
		status = pjsua_init(&cfg, &log_cfg, NULL);
		if (status != PJ_SUCCESS)
		{
			error_exit("Error in pjsua_init()", status);
			return 0;
		}
    }
	
    /* Add UDP transport. */
    {
		pjsua_transport_config cfg;
		
		pjsua_transport_config_default(&cfg);
		cfg.port = 5060;
		status = pjsua_transport_create(PJSIP_TRANSPORT_UDP, &cfg, NULL);
		if (status != PJ_SUCCESS)
		{
			error_exit("Error creating transport", status);
			return 0;
		}
    }
	
    /* Initialization is done, now start pjsua */
    status = pjsua_start();
    if (status != PJ_SUCCESS)
	{
		error_exit("Error starting pjsua", status);
		return 0;
	}
	
	return 1;
}


///////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UIViewController LifeCycle
///////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initModel];
    [self initUI];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(NSUInteger)supportedInterfaceOrientations
{
    NSLog(@"supportedInterfaceOrientations...");
    return UIInterfaceOrientationPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (BOOL)shouldAutorotate
{
    return true;
}

- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    BOOL allowed = NO;
    if(interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        allowed = YES;
    }
    return allowed;
}


///////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private Methods
///////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)initUI
{
    [_btnCall addTarget:self action:@selector(wasDragged:withEvent:)
     forControlEvents:UIControlEventTouchDragInside];
    [_btnHeadset addTarget:self action:@selector(wasDragged:withEvent:)
       forControlEvents:UIControlEventTouchDragInside];
    
    [_sldrHeadset setMinimumTrackImage:[[UIImage imageNamed:@"transparentBar"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 0)] forState:UIControlStateNormal];
    [_sldrHeadset setMaximumTrackImage:[[UIImage imageNamed:@"transparentBar"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 4)] forState:UIControlStateNormal];
    
    UIImage *knobHeadsetImage = [UIImage imageNamed:@"buttonHeadSet.png"];
    [_sldrHeadset setThumbImage:knobHeadsetImage forState:UIControlStateNormal];
    [_sldrHeadset setThumbImage:knobHeadsetImage forState:UIControlStateSelected];
    [_sldrHeadset setThumbImage:knobHeadsetImage forState:UIControlStateHighlighted];
    _sldrHeadset.value = 0.0;
    
    [_sldrCall setMinimumTrackImage:[[UIImage imageNamed:@"transparentBar"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 0)] forState:UIControlStateNormal];
    [_sldrCall setMaximumTrackImage:[[UIImage imageNamed:@"transparentBar"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 4)] forState:UIControlStateNormal];

    UIImage *knobCallImage = [UIImage imageNamed:@"Call.png"];
    [_sldrCall setThumbImage:knobCallImage forState:UIControlStateNormal];
    [_sldrCall setThumbImage:knobCallImage forState:UIControlStateSelected];
    [_sldrCall setThumbImage:knobCallImage forState:UIControlStateHighlighted];
    _sldrCall.value = 1.0;
    
    _speakerVolume.value = appVolume;
}

- (void)initModel
{
    redArrowCounter = 0;
    greenArrowCounter = 0;
    isCalling = NO;
    isListening = NO;
    isPaused = NO;
    isFromSuccessfulDrag = NO;
    isCallPopShown = NO;

    printf("\naccs= %d \n",pjsua_acc_get_count());
	if (pjsip_init(NULL,NULL)) pjsip_regist_account("user", "pass", "yourvoipserverhere.com", "realm");
    
    NSString *strVolume = [[NSUserDefaults standardUserDefaults] valueForKey:@"VOLUME"];
    if (strVolume.length > 0)
    {
        appVolume = [strVolume floatValue];
    }
    else
    {
        appVolume = 0.5f;
    }
    
    
}


- (void)wasDragged:(UIButton *)button withEvent:(UIEvent *)event
{
    NSLog(@"DRAGGED");
	// get the touch
	UITouch *touch = [[event touchesForView:button] anyObject];
    
	// get delta
	CGPoint previousLocation = [touch previousLocationInView:button];
	CGPoint location = [touch locationInView:button];
	CGFloat delta_x = location.x - previousLocation.x;
	CGFloat delta_y = location.y - previousLocation.y;
    
	// move button
	button.center = CGPointMake(button.center.x + delta_x,
                                button.center.y + delta_y);
}


- (void)animateGreenArrow
{
    if (greenArrowCounter % 2) {
        NSLog(@"EVEN : %d",greenArrowCounter);
        _imgGreenArrow1.image = [UIImage imageNamed:@"rightArrow2.png"];
        _imgGreenArrow2.image = [UIImage imageNamed:@"rightArrow1.png"];
    }
    else
    {
        NSLog(@"ODD : %d",greenArrowCounter);
        _imgGreenArrow1.image = [UIImage imageNamed:@"rightArrow1.png"];
        _imgGreenArrow2.image = [UIImage imageNamed:@"rightArrow2.png"];
    }
    greenArrowCounter++;
}

- (void)animateRedArrow
{
    if (redArrowCounter % 2) {
        NSLog(@"EVEN : %d",redArrowCounter);
        _imgRedArrow1.image = [UIImage imageNamed:@"leftArrow2.png"];
        _imgRedArrow2.image = [UIImage imageNamed:@"leftArrow1.png"];
    }
    else
    {
        NSLog(@"ODD : %d",redArrowCounter);
        _imgRedArrow1.image = [UIImage imageNamed:@"leftArrow1.png"];
        _imgRedArrow2.image = [UIImage imageNamed:@"leftArrow2.png"];
    }
    redArrowCounter++;
}


- (void)displayChargePopUp
{
    isCallPopShown = YES;
    _vwChargePopUp.hidden = NO;
    [self.view bringSubviewToFront:_vwChargePopUp];
    _imgInfo.hidden = YES;
}

- (void)initiateListen
{
    pjsip_make_call("sip:16001000119@207.97.161.99");
    pjsua_conf_adjust_tx_level(0, appVolume);
    pjsua_conf_adjust_rx_level(0, appVolume);
    
}

- (void)initiateCall
{
    if (isListening) {
        pjsip_hangup();
        isListening = NO;
    }
    
    NSString *phoneNumber = @"tel://4013470429";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark IBActions
///////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)touchBeganForScrollWithTag:(id)sender
{
    UIButton *btnSender = (UIButton *)sender;
    int tag = (int)btnSender.tag;
    if (tag == 1001) {
        if (!isListening) {
            _vwHeadSetNormal.hidden = YES;
            _vwHeadSetCollapse.hidden = NO;
            tmrHeadsetArrowAnimation = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                        target:self
                                                                      selector:@selector(animateGreenArrow)
                                                                      userInfo:nil
                                                                       repeats:YES];
            if (isCallPopShown) {
                isCallPopShown = NO;
                _vwChargePopUp.hidden = YES;
                [self.view sendSubviewToBack:_vwChargePopUp];
                _imgInfo.hidden = NO;
            }
        }
       
    }
    else if (tag == 2001)
    {
        _vwCallNormal.hidden = YES;
        _vwCallCollapse.hidden = NO;
        tmrCallArrowAnimation = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                 target:self
                                                               selector:@selector(animateRedArrow)
                                                               userInfo:nil
                                                                repeats:YES];
    }
}

-(IBAction)eventTouchUp:(id)sender{
    UIButton *btnSender = (UIButton *)sender;
    int tag = (int)btnSender.tag;
    if (tag == 1001)
    {
        NSLog(@"single Tap on Headset");
        if (!isListening && !isPaused) {
            //START LISTENING
            _vwHeadSetNormal.hidden = NO;
            _vwHeadSetCollapse.hidden = YES;
            [tmrHeadsetArrowAnimation invalidate];
            greenArrowCounter = 0;
            _sldrHeadset.value = 0.0;
        }
        else if(isListening && !isPaused)
        {
            //PAUSE
            if (isFromSuccessfulDrag) {
                //IGNORE
                isFromSuccessfulDrag = NO;
            }
            else
            {
                pjsip_hangup();
                isPaused = YES;
                isListening = NO;
                UIImage *knobHeadsetImage = [UIImage imageNamed:@"buttonHeadSet.png"];
                [_sldrHeadset setThumbImage:knobHeadsetImage forState:UIControlStateNormal];
                [_sldrHeadset setThumbImage:knobHeadsetImage forState:UIControlStateSelected];
                [_sldrHeadset setThumbImage:knobHeadsetImage forState:UIControlStateHighlighted];
                
            }
        }
        else if(isListening && isPaused)
        {
            //CONTINUE LISTENING
            [self initiateListen];
        }
    }
    else if (tag == 2001)
    {
        NSLog(@"single Tap on Call");
        _vwCallNormal.hidden = NO;
        _vwCallCollapse.hidden = YES;
        [tmrCallArrowAnimation invalidate];
        redArrowCounter = 0;
        _sldrCall.value = 1.0;
    }
}

- (IBAction)volumeChangeValue:(id)sender
{
    appVolume = _speakerVolume.value;
    pjsua_conf_adjust_tx_level(0, appVolume);
    pjsua_conf_adjust_rx_level(0, appVolume);
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%.2f",appVolume] forKey:@"VOLUME"];
}


- (IBAction)changedValue:(UISlider *)sender
{
    if (sender.tag == 1001)
    {
        float width = sender.value * 100;
        _imgSlideHeaderCover.frame = CGRectMake(23, 12, width, 39);
        if (sender.value == 1.0) {
            _vwHeadSetNormal.hidden = NO;
            _vwHeadSetCollapse.hidden = YES;
            [tmrHeadsetArrowAnimation invalidate];
            greenArrowCounter = 0;
            _sldrHeadset.value = 0.0;
            if (!isListening) {
                isFromSuccessfulDrag = YES;
                isListening = YES;
                if (isPaused) {
                    isPaused = NO;
                }
                UIImage *knobPauseImage = [UIImage imageNamed:@"buttonPause.png"];
                [_sldrHeadset setThumbImage:knobPauseImage forState:UIControlStateNormal];
                [_sldrHeadset setThumbImage:knobPauseImage forState:UIControlStateSelected];
                [_sldrHeadset setThumbImage:knobPauseImage forState:UIControlStateHighlighted];
                //START LISTEN
                //[self initiateListen];
                [self performSelector:@selector(initiateListen) withObject:nil afterDelay:0.3];
            }
        }
    }
    else if (sender.tag == 2001)
    {
        float width = (sender.value - 1) * -100;
        NSLog(@"WIDTH : %f",width);
        _imgSlideCallCover.frame = CGRectMake(131 - width, 10, width, 39);
        if (sender.value == 0.0) {
            _vwCallNormal.hidden = NO;
            _vwCallCollapse.hidden = YES;
            [tmrCallArrowAnimation invalidate];
            redArrowCounter = 0;
            _sldrCall.value = 1.0;
            isCalling = YES;
            //START CALL
            [self displayChargePopUp];
        }
    }
}


- (IBAction)btnContinueClicked:(id)sender
{
    isCallPopShown = NO;
    isCalling = YES;
    [self.view sendSubviewToBack:_vwChargePopUp];
    _vwChargePopUp.hidden = YES;
    _imgInfo.hidden = NO;
    [self initiateCall];
}

- (IBAction)btnCancelClicked:(id)sender
{
    isCallPopShown = NO;
    isCalling = NO;
    [self.view sendSubviewToBack:_vwChargePopUp];
    _vwChargePopUp.hidden = YES;
    _imgInfo.hidden = NO;
}

- (IBAction)btnInformationClicked:(id)sender
{
    [self performSegueWithIdentifier:@"toInformationSegue" sender:nil];
}

- (IBAction)btnSettingsClicked:(id)sender
{
    [self performSegueWithIdentifier:@"toSettingsSegue" sender:nil];
}




@end
