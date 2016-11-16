/*
 *  hci_asr_recorder_visualcontrol.h
 *  hci_asr_recorder_visualcontrol
 *
 *  Created by  mini on 13-10-31.
 *  Copyright 2013 __Sinovoice__. All rights reserved.
 *
 */

/** @defgroup HCI_ASR_RECORDER_VISUAL_CONTROL 灵云ASR录音机控件 */
/* @{ */

#import "hci_asr.h"
@protocol AsrRecorderCallBackDelegate <NSObject>

@required

/**
 * @brief	出错通知
 * @param	errorCode				错误代码
 * @param	errInfo					错误代码所代表的的具体信息
 * @details 此处错误代码为内部控件出现时的错误信息，可能是链接不到服务器，也可能是参数配置错误或者是调用顺序不正确。
 */

- (void) onError: (HCI_ERR_CODE) errCode errInfo:(NSString *)errInfo;

/**
 * @brief	回调识别结果
 * @param	asrResult				结果结构体
 */

- (void) onResult: (ASR_RECOG_RESULT*) asrResult;

@end

@interface JTAsrRecorderDialog : NSObject


/**
 * @brief	单例实现录音机控件对象
 */
+ (JTAsrRecorderDialog*) sharedInstance;

/**
 * @brief	初始化录音机控件
 * @param	initParams		录音机初始化配置参数
 * @param	delegate		回调对象
 * @return	void
 *
 * @par 录音机初始化配置串定义：
 * 配置串是由"字段=值"的形式给出的一个字符串，多个字段之间以','隔开。字段名不分大小写。本配置串用于本地识别的字典载入和配置。
 * 若不需要使用本地能力，此配置串可以传NULL或者""。参数数据不分大小写。
 * @n@n
 *	<table>
 *		<tr>
 *			<td><b>字段</b></td>
 *			<td><b>取值或示例</b></td>
 *			<td><b>缺省值</b></td>
 *			<td><b>含义</b></td>
 *			<td><b>详细说明</b></td>
 *		</tr>
 *		<tr>
 *			<td>dataPath</td>
 *			<td>opt/myapp/asr_data/</td>
 *			<td>空</td>
 *			<td>语音识别本地资源所在路径</td>
 *			<td>如果不使用本地语音识别能力，可以不传此项</td>
 *		</tr>
 *		<tr>
 *			<td>initCapKeys</td>
 *			<td>asr.local.grammar</td>
 *			<td>空</td>
 *			<td>初始化所需的本地能力</td>
 *			<td>多个能力以';'隔开，忽略传入的云端能力key。如果不使用本地识别能力，可以不传此项</td>
 *		</tr>
 *		<tr>
 *			<td>fileFlag</td>
 *			<td>none, android_so</td>
 *			<td>none</td>
 *			<td>获取本地文件名的特殊标记</td>
 *			<td>参见下面的注释</td>
 *		</tr>
 *	</table>
 *
 */

- (void) initWithConfig:(NSString *)initConfig andDelegate:(id<AsrRecorderCallBackDelegate>)delegate;

/**
 * @brief	显示并启动录音机
 * @param	recogConfig		配置串 可通过deviceId指定录音设备，其余参数
 * @param	grammar			语法文件(只有当配置串grammarType为wordlist、jsgf或wfst时有效）
 * @return	void
 *
 * @details
 * 配置中包含端点检测配制项
 * @note
 * 录音机仅提供对 pcm8k16bit pcm16k16bit 格式的支持
 * 如果不是录音机支持的格式，会在 Callback_RecorderEventStateChange 中触发打开设备失败的事件
 * 
 *
 * @par 录音机启动的配置串定义：
 * 配置串是由"字段=值"的形式给出的一个字符串，多个字段之间以','隔开。字段名不分大小写。本配置串用于本地识别的字典载入和配置。
 * 若不需要使用本地能力，此配置串可以传NULL或者""。参数数据不分大小写。
 * @n@n
 *	<table>
 *		<tr>
 *			<td><b>字段</b></td>
 *			<td><b>取值或示例</b></td>
 *			<td><b>缺省值()</b></td>
 *			<td><b>含义</b></td>
 *			<td><b>详细说明</b></td>
 *		</tr>
 *		<tr>
 *			<td>capKey</td>
 *			<td>asr.cloud.freetalk</td>
 *			<td>无</td>
 *			<td>语音识别能力key</td>
 *			<td>此项必填。参见 @ref hci_asr_page 。每个session只能定义一种能力，并且过程中不能改变。</td>
 *		</tr>
 *		<tr>
 *			<td>realtime</td>
 *			<td>no, yes,rt</td>
 *			<td>no</td>
 *			<td>是否启动实时识别，本地语法识别和云端自由说能力支持</td>
 *			<td>no,非实时识别模式<br/>
 *				yes,实时识别模式<br/>
 *				rt,实时反馈识别结果,asr.cloud.dialog不支持该配置</td>
 *		</tr>
 *		<tr>
 *			<td>maxSeconds</td>
 *			<td>[1,60]</td>
 *			<td>30</td>
 *			<td>检测时输入的最大语音长度, 以秒为单位</td>
 *			<td>如果输入的声音超过此长，<br/>
 *				非实时识别返回(@ref HCI_ERR_DATA_SIZE_TOO_LARGE)<br/>
 *				实时识别返回(@ref HCI_ERR_ASR_REALTIME_END)<br/>
 *				端点检测认为缓冲区满 (@ref VAD_BUFF_FULL)</td>
 *		</tr>
 *		<tr>
 *			<td>audioFormat</td>
 *			<td>pcm8k16bit, pcm16k16bit</td>
 *			<td>pcm16k16bit</td>
 *			<td>传入的语音数据格式</td>
 *			<td>目前只支持直接传入pcm格式的数据</td>
 *		</tr> 
 *		<tr>
 *			<td>grammarType</td>
 *			<td>id, wordlist, jsgf, wfst</td>
 *			<td>id</td>
 *			<td>使用的语法类型</td>
 *			<td>只对grammar识别有效：指定语法格式。<br/>
 *				- id: 使用云端预置的或者本地加载的语法编号进行识别
 *				- wordlist: 将 grammarData 数据当做以'\\r\\n'隔开的词表进行识别
 *				- jsgf: 将 grammarData 数据当做语法文件进行识别，语法文件格式请参见《捷通华声iSpeakGrammar语法规则说明.pdf》
 *				- wfst: 通过hci_asr_save_compiled_grammar接口保存的语法文件，只支持文件加载
 *			</td>
 *		</tr>
 *		<tr>
 *			<td>grammarId</td>
 *			<td>1</td>
 *			<td>空</td>
 *			<td>识别使用的语法编号</td>
 *			<td>只对grammar识别中且grammarType设置为id时有效：<br/>
 *				- 此id可以是云端预置的某个语法Id，
 *				- 也可以是利用 hci_asr_load_grammar() 函数获得的本地的语法Id。这两类语法Id分别用于
 *				本地或者云端的语法识别能力，两者之间没有关系。灵云平台ASR云识别能力会预置语法，具体可用的语法编号可以在开发时咨询捷通华声。</td>
 *		</tr>
 *		<tr>
 *			<td>isFile</td>
 *			<td>yes, no</td>
 *			<td>no</td>
 *			<td>输入参数是文件名还是内存数据</td>
 *			<td>只对本地grammar识别有效：<br/>
 *			    - yes表示的是一个语法文件名，
 *				- no表示的直接是内存中的语法数据
 *			</td>
 *		</tr>
 *		<tr>
 *			<td>domain</td>
 *			<td>music</td>
 *			<td>空</td>
 *			<td>识别使用的领域</td>
 *			<td>只对freetalk识别中有效：使用指定领域的模型进行识别。<br/>
 *				- 如果capKey的能力未指定特定领域, 则可以使用domain进行进一步指定领域。
 *				- 如果capKey的能力已经指定了特定领域则不能使用此配置项，或者只能使用一致的领域。<br/>
 *				- 此项可选。具体可用的领域可以在开发时咨询捷通华声。</td>
 *		</tr>
 *		<tr>
 *			<td>addPunc</td>
 *			<td>yes, no</td>
 *			<td>no</td>
 *			<td>是否添加标点</td>
 *			<td>yes表示识别过程中添加标点，no表示不添加标点</td>
 *		</tr>
 *		<tr>
 *			<td>candNum</td>
 *			<td>1-10</td>
 *			<td>10</td>
 *			<td>识别候选结果个数</td>
 *			<td></td>
 *		</tr>
 *		<tr>
 *			<td>encode</td>
 *			<td>none, ulaw, alaw, speex,opus</td>
 *			<td>none</td>
 *			<td>使用的编码格式</td>
 *			<td>只对云端识别有效：对传入的语音数据进行编码传输。<br/>
 *				- 具体audioFormat和encode的使用方法参见下面的详细说明。</td>
 *		</tr> 
 *		<tr>
 *			<td>encLevel</td>
 *			<td>0-10</td>
 *			<td>7</td>
 *			<td>压缩等级</td>
 *			<td>只对云端识别有效：</td>
 *		</tr>
 *		<tr>
 *			<td>vadHead</td>
 *			<td>[0,30000]</td>
 *			<td>10000</td>
 *			<td>开始的静音检测毫秒数</td>
 *			<td>当声音开始的静音超过此项指定的毫秒数时，认为没有检测到声音<br/>
 *				如果此值为0，则表示不进行起点检测</td>
 *		</tr> 
 *		<tr>
 *			<td>vadTail</td>
 *			<td>[0,30000]</td>
 *			<td>500</td>
 *			<td>端点检测的末尾毫秒数</td>
 *			<td>检测到起点后语音数据出现静音并且静音时间超过此项指定的毫秒数时，认为声音结束<br/>
 *				如果此值为0，则表示不进行末端检测</td>
 *		</tr>
 *		<tr>
 *			<td>vadSeg</td>
 *			<td>[0,30000]</td>
 *			<td>500</td>
 *			<td>端点检测的分段间隔毫秒数</td>
 *			<td>目前只对云端自由说实时反馈模式生效，<br/>
 *				检测到起点后语音数据出现静音并且静音时间超过此项指定的毫秒数时，认为音频进行分段<br/>
 *				如果此值为0或设置大于等于vadtail，则表示不进行分段</td>
 *		</tr>
 *		<tr>
 *			<td>intention</td>
 *			<td>poi</td>
 *			<td>空</td>
 *			<td>识别意图</td>
 *			<td>仅在云端dialog识别中有效：<br/>
 *				- 云端识别会自动将识别结果进行意图分析，并返回json格式的意图结果。该项取值具体信息请咨询捷通华声公司</td>
 *		</tr>
 *		<tr>
 *			<td>needContent</td>
 *			<td>yes, no</td>
 *			<td>yes</td>
 *			<td>是否需要意图识别内容</td>
 *			<td>仅在云端dialog识别中有效：<br/>
 *				指定是否需要意图识别内容，即意图识别后获取相应的内容或答案。</td>
 *		</tr>
 *	</table>
 * @n@n
*/ 

- (void)showWithConfig:(NSString*)recogConfig andGrammar:(NSString*)grammar;

@end





