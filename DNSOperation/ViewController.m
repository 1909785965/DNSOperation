//
//  ViewController.m
//  DNSOperation
//
//  Created by SR Zhang on 2020/8/28.
//  Copyright © 2020 SR Zhang. All rights reserved.
// https://www.jianshu.com/p/4b1d77054b35

#import "ViewController.h"
#import "SROperation.h"


@interface ViewController ()

/* 剩余火车票数 */
@property (nonatomic, assign) int ticketSurplusCount;
@property (readwrite, nonatomic, strong) NSLock *lock;

@end

@implementation ViewController

/*
 NSOperation 常用属性和方法
   - (void)cancel; 可取消操作，实质是标记 isCancelled 状态。
   - (BOOL)isFinished; 判断操作是否已经结束。
   - (BOOL)isCancelled; 判断操作是否已经标记为取消。
   - (BOOL)isExecuting; 判断操作是否正在在运行。
   - (BOOL)isReady; 判断操作是否处于准备就绪状态，这个值和操作的依赖关系相关。
   - (void)waitUntilFinished; 阻塞当前线程，直到该操作结束。可用于线程执行顺序的同步。
   - (void)setCompletionBlock:(void (^)(void))block; completionBlock 会在当前操作执行完毕时执行 completionBlock。
   - (void)addDependency:(NSOperation *)op; 添加依赖，使当前操作依赖于操作 op 的完成。
   - (void)removeDependency:(NSOperation *)op; 移除依赖，取消当前操作对操作 op 的依赖。
   @property (readonly, copy) NSArray<NSOperation *> *dependencies; 在当前操作开始执行之前完成执行的所有操作对象数组。
 */

/*
 NSOperationQueue 常用属性和方法
    - (void)cancelAllOperations; 可以取消队列的所有操作。
    - (BOOL)isSuspended; 判断队列是否处于暂停状态。 YES 为暂停状态，NO 为恢复状态。
    - (void)setSuspended:(BOOL)b; 可设置操作的暂停和恢复，YES 代表暂停队列，NO 代表

    - (void)waitUntilAllOperationsAreFinished; 阻塞当前线程，直到队列中的操作全部执行
 
    - (void)addOperationWithBlock:(void (^)(void))block; 向队列中添加一个 NSBlockOperation 类型操作对象。
    - (void)addOperations:(NSArray *)ops waitUntilFinished:(BOOL)wait; 向队列中添加操作数组，wait 标志是否阻塞当前线程直到所有操作结束
    - (NSArray *)operations; 当前在队列中的操作数组（某个操作执行结束后会自动从这个数组清除）。
    - (NSUInteger)operationCount; 当前队列中的操作数。
 
    + (id)currentQueue; 获取当前队列，如果当前线程不是在 NSOperationQueue 上运行则返回 nil。
    + (id)mainQueue; 获取主队列。
 */


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    
//    [self useInvocationOperation];
    // 在其他线程使用子类 NSInvocationOperation
//    [NSThread detachNewThreadSelector:@selector(useInvocationOperation) toTarget:self withObject:nil];//如果在其他线程中执行操作，则打印结果为其他线程。

//    [self useBlockOperation];

//    [self useCustomOperation];
    
//    [self addOperationToQueue];
    
//    [self addOperationWithBlockToQueue];
    
//    [self setMaxConcurrentOperationCount];
    
//    [self addDependency];
    
//    [self initTicketStatusNotSave];
    
    [self initTicketStatusSave];
    

    
}

#pragma mark -1
/**
* 使用子类 NSInvocationOperation
*/
-(void)useInvocationOperation{
    
    //在没有使用 NSOperationQueue、在主线程中单独使用使用子类 NSInvocationOperation 执行一个操作的情况下，操作是在当前线程执行的，并没有开启新线程。
    // 1.创建 NSInvocationOperation 对象
    NSInvocationOperation * op = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(task1) object:nil];
    // 2.调用 start 方法开始执行操作
    [op start];
}
/**
* 任务1
*/
-(void)task1{
    
    for (int i = 0; i<2; i++) {
        [NSThread sleepForTimeInterval:2];
        NSLog(@"InvocationOperation--%@",[NSThread currentThread]);///<NSThread: 0x6000007900c0>{number = 1, name = main}
    }
}

#pragma mark -2
/**
* 使用子类 NSBlockOperation
*/
-(void)useBlockOperation{
    
    //在没有使用 NSOperationQueue、在主线程中单独使用 NSBlockOperation 执行一个操作的情况下，操作是在当前线程执行的，并没有开启新线程。
    // 1.创建 NSBlockOperation 对象
    NSBlockOperation * op = [NSBlockOperation blockOperationWithBlock:^{
       
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"BlockOperation---%@", [NSThread currentThread]); // 打印当前线程 <NSThread: 0x600000828440>{number = 1, name = main}
        }
    }];
    
    // 2.调用 start 方法开始执行操作
    [op start];
}

#pragma mark -3
/**
 * 使用自定义继承自 NSOperation 的子类
 */
- (void)useCustomOperation {
    
    //在没有使用 NSOperationQueue、在主线程单独使用自定义继承自 NSOperation 的子类的情况下，是在主线程执行操作，并没有开启新线程。
    // 1.创建 YSCOperation 对象
    SROperation *op = [[SROperation alloc] init];
    
    NSOperationQueue * queue = [[NSOperationQueue alloc]init];
    // 2.调用 start 方法开始执行操作
    //[op start]; //没放队列中还是在主线程执行
    
    [queue addOperation:op];//添加到队列中则开新线程
    
    
}

#pragma mark -4
/**
* 使用 addOperation: 将操作加入到操作队列中
*/
-(void)addOperationToQueue{
    
    //使用 NSOperation 子类创建操作，并使用 addOperation: 将操作加入到操作队列后能够开启新线程，进行并发执行。
    // 1.创建队列
    NSOperationQueue * queue = [[NSOperationQueue alloc]init];
    
    // 2.创建操作
    // 使用 NSInvocationOperation 创建操作1
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];

    // 使用 NSInvocationOperation 创建操作2
    NSInvocationOperation *op2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];

    // 使用 NSBlockOperation 创建操作3
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"NSBlockOperation加入到队列中---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];

    // 3.使用 addOperation: 添加所有操作到队列中
    [queue addOperation:op1]; // [op1 start]
    [queue addOperation:op2]; // [op2 start]
    [queue addOperation:op3]; // [op3 start]
}

#pragma mark -5
/**
 * 使用 addOperationWithBlock: 将操作加入到操作队列中
 */
- (void)addOperationWithBlockToQueue {
    //使用 addOperationWithBlock: 将操作加入到操作队列后能够开启新线程，进行并发执行。
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];

    // 2.使用 addOperationWithBlock: 添加操作到队列中
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"队列添加OperationBlock1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"队列添加OperationBlock2---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"队列添加OperationBlock3---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
}

#pragma mark -6
/**
 * 设置 MaxConcurrentOperationCount（最大并发操作数）
 */
- (void)setMaxConcurrentOperationCount {

    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];

    // 2.设置最大并发操作数
//    queue.maxConcurrentOperationCount = 1; // 串行队列
 queue.maxConcurrentOperationCount = 2; // 并发队列
// queue.maxConcurrentOperationCount = 8; // 并发队列

    // 3.添加操作
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"3---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"4---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
}

#pragma mark -7
/**
 * 操作依赖
 * 使用方法：addDependency:
 */
- (void)addDependency {

    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];

    // 2.创建操作
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];

    // 3.添加依赖 通过添加操作依赖，无论运行几次，其结果都是 op1 先执行，op2 后执行。
    [op2 addDependency:op1]; // 让op2 依赖于 op1，则先执行op1，在执行op2

    // 4.添加操作到队列中
    [queue addOperation:op1];
    [queue addOperation:op2];
}

#pragma mark -8
/**
 * 线程间通信 异步操作后回到主线程
 */
- (void)communication {

    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];

    // 2.添加操作
    [queue addOperationWithBlock:^{
        // 异步进行耗时操作
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }

        // 回到主线程
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // 进行一些 UI 刷新等操作
            for (int i = 0; i < 2; i++) {
                [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
                NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
            }
        }];
    }];
}

#pragma mark -9 线程安全
/**
 * 非线程安全：不使用 NSLock
 * 初始化火车票数量、卖票窗口(非线程安全)、并开始卖票
 */
- (void)initTicketStatusNotSave {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    
    self.ticketSurplusCount = 50;
    
    // 1.创建 queue1,queue1 代表北京火车票售卖窗口
    NSOperationQueue *queue1 = [[NSOperationQueue alloc] init];
    queue1.maxConcurrentOperationCount = 1;
    
    // 2.创建 queue2,queue2 代表上海火车票售卖窗口
    NSOperationQueue *queue2 = [[NSOperationQueue alloc] init];
    queue2.maxConcurrentOperationCount = 1;
   
    
    // 3.创建卖票操作 op1
    __weak typeof(self) weakSelf = self;
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf saleTicketNotSafe];
    }];
    
    // 4.创建卖票操作 op2
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf saleTicketNotSafe];
    }];
    
    // 5.添加操作，开始卖票
    [queue1 addOperation:op1];
    [queue2 addOperation:op2];
}

/**
 * 售卖火车票(非线程安全)
 */
- (void)saleTicketNotSafe {
    while (1) {
        
        if (self.ticketSurplusCount > 0) {
            
            //如果还有票，继续售卖
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数:%d 窗口:%@", self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        } else {
            NSLog(@"所有火车票均已售完");
            break;
        }
    }
}

/**
 * 线程安全：使用 NSLock 加锁
 * 初始化火车票数量、卖票窗口(线程安全)、并开始卖票
 */
- (void)initTicketStatusSave {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    
    self.ticketSurplusCount = 50;
    
    self.lock = [[NSLock alloc] init];
    // 1.创建 queue1,queue1 代表北京火车票售卖窗口
    NSOperationQueue *queue1 = [[NSOperationQueue alloc] init];
    queue1.maxConcurrentOperationCount = 1;
    
    // 2.创建 queue2,queue2 代表上海火车票售卖窗口
    NSOperationQueue *queue2 = [[NSOperationQueue alloc] init];
    queue2.maxConcurrentOperationCount = 1;
    
    // 3.创建卖票操作 op1
    __weak typeof(self) weakSelf = self;
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf saleTicketSafe];
    }];
    
    // 4.创建卖票操作 op2
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf saleTicketSafe];
    }];
    
    // 5.添加操作，开始卖票
    [queue1 addOperation:op1];
    [queue2 addOperation:op2];
}

/**
 * 售卖火车票(线程安全)
 */
- (void)saleTicketSafe {
    while (1) {
        // 加锁
        [self.lock lock];
        
        if (self.ticketSurplusCount > 0) {
            //如果还有票，继续售卖
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数:%d 窗口:%@", self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        }
        // 解锁
        [self.lock unlock];
        
        if (self.ticketSurplusCount <= 0) {
            NSLog(@"所有火车票均已售完");
            break;
        }
    }
}


@end
