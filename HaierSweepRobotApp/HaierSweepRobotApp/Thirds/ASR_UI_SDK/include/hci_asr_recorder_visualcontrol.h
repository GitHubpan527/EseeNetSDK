/*
 *  hci_asr_recorder_visualcontrol.h
 *  hci_asr_recorder_visualcontrol
 *
 *  Created by  mini on 13-10-31.
 *  Copyright 2013 __Sinovoice__. All rights reserved.
 *
 */

/** @defgroup HCI_ASR_RECORDER_VISUAL_CONTROL ����ASR¼�����ؼ� */
/* @{ */

#import "hci_asr.h"
@protocol AsrRecorderCallBackDelegate <NSObject>

@required

/**
 * @brief	����֪ͨ
 * @param	errorCode				�������
 * @param	errInfo					�������������ĵľ�����Ϣ
 * @details �˴��������Ϊ�ڲ��ؼ�����ʱ�Ĵ�����Ϣ�����������Ӳ�����������Ҳ�����ǲ������ô�������ǵ���˳����ȷ��
 */

- (void) onError: (HCI_ERR_CODE) errCode errInfo:(NSString *)errInfo;

/**
 * @brief	�ص�ʶ����
 * @param	asrResult				����ṹ��
 */

- (void) onResult: (ASR_RECOG_RESULT*) asrResult;

@end

@interface JTAsrRecorderDialog : NSObject


/**
 * @brief	����ʵ��¼�����ؼ�����
 */
+ (JTAsrRecorderDialog*) sharedInstance;

/**
 * @brief	��ʼ��¼�����ؼ�
 * @param	initParams		¼������ʼ�����ò���
 * @param	delegate		�ص�����
 * @return	void
 *
 * @par ¼������ʼ�����ô����壺
 * ���ô�����"�ֶ�=ֵ"����ʽ������һ���ַ���������ֶ�֮����','�������ֶ������ִ�Сд�������ô����ڱ���ʶ����ֵ���������á�
 * ������Ҫʹ�ñ��������������ô����Դ�NULL����""���������ݲ��ִ�Сд��
 * @n@n
 *	<table>
 *		<tr>
 *			<td><b>�ֶ�</b></td>
 *			<td><b>ȡֵ��ʾ��</b></td>
 *			<td><b>ȱʡֵ</b></td>
 *			<td><b>����</b></td>
 *			<td><b>��ϸ˵��</b></td>
 *		</tr>
 *		<tr>
 *			<td>dataPath</td>
 *			<td>opt/myapp/asr_data/</td>
 *			<td>��</td>
 *			<td>����ʶ�𱾵���Դ����·��</td>
 *			<td>�����ʹ�ñ�������ʶ�����������Բ�������</td>
 *		</tr>
 *		<tr>
 *			<td>initCapKeys</td>
 *			<td>asr.local.grammar</td>
 *			<td>��</td>
 *			<td>��ʼ������ı�������</td>
 *			<td>���������';'���������Դ�����ƶ�����key�������ʹ�ñ���ʶ�����������Բ�������</td>
 *		</tr>
 *		<tr>
 *			<td>fileFlag</td>
 *			<td>none, android_so</td>
 *			<td>none</td>
 *			<td>��ȡ�����ļ�����������</td>
 *			<td>�μ������ע��</td>
 *		</tr>
 *	</table>
 *
 */

- (void) initWithConfig:(NSString *)initConfig andDelegate:(id<AsrRecorderCallBackDelegate>)delegate;

/**
 * @brief	��ʾ������¼����
 * @param	recogConfig		���ô� ��ͨ��deviceIdָ��¼���豸���������
 * @param	grammar			�﷨�ļ�(ֻ�е����ô�grammarTypeΪwordlist��jsgf��wfstʱ��Ч��
 * @return	void
 *
 * @details
 * �����а����˵���������
 * @note
 * ¼�������ṩ�� pcm8k16bit pcm16k16bit ��ʽ��֧��
 * �������¼����֧�ֵĸ�ʽ������ Callback_RecorderEventStateChange �д������豸ʧ�ܵ��¼�
 * 
 *
 * @par ¼�������������ô����壺
 * ���ô�����"�ֶ�=ֵ"����ʽ������һ���ַ���������ֶ�֮����','�������ֶ������ִ�Сд�������ô����ڱ���ʶ����ֵ���������á�
 * ������Ҫʹ�ñ��������������ô����Դ�NULL����""���������ݲ��ִ�Сд��
 * @n@n
 *	<table>
 *		<tr>
 *			<td><b>�ֶ�</b></td>
 *			<td><b>ȡֵ��ʾ��</b></td>
 *			<td><b>ȱʡֵ()</b></td>
 *			<td><b>����</b></td>
 *			<td><b>��ϸ˵��</b></td>
 *		</tr>
 *		<tr>
 *			<td>capKey</td>
 *			<td>asr.cloud.freetalk</td>
 *			<td>��</td>
 *			<td>����ʶ������key</td>
 *			<td>�������μ� @ref hci_asr_page ��ÿ��sessionֻ�ܶ���һ�����������ҹ����в��ܸı䡣</td>
 *		</tr>
 *		<tr>
 *			<td>realtime</td>
 *			<td>no, yes,rt</td>
 *			<td>no</td>
 *			<td>�Ƿ�����ʵʱʶ�𣬱����﷨ʶ����ƶ�����˵����֧��</td>
 *			<td>no,��ʵʱʶ��ģʽ<br/>
 *				yes,ʵʱʶ��ģʽ<br/>
 *				rt,ʵʱ����ʶ����,asr.cloud.dialog��֧�ָ�����</td>
 *		</tr>
 *		<tr>
 *			<td>maxSeconds</td>
 *			<td>[1,60]</td>
 *			<td>30</td>
 *			<td>���ʱ����������������, ����Ϊ��λ</td>
 *			<td>�����������������˳���<br/>
 *				��ʵʱʶ�𷵻�(@ref HCI_ERR_DATA_SIZE_TOO_LARGE)<br/>
 *				ʵʱʶ�𷵻�(@ref HCI_ERR_ASR_REALTIME_END)<br/>
 *				�˵�����Ϊ�������� (@ref VAD_BUFF_FULL)</td>
 *		</tr>
 *		<tr>
 *			<td>audioFormat</td>
 *			<td>pcm8k16bit, pcm16k16bit</td>
 *			<td>pcm16k16bit</td>
 *			<td>������������ݸ�ʽ</td>
 *			<td>Ŀǰֻ֧��ֱ�Ӵ���pcm��ʽ������</td>
 *		</tr> 
 *		<tr>
 *			<td>grammarType</td>
 *			<td>id, wordlist, jsgf, wfst</td>
 *			<td>id</td>
 *			<td>ʹ�õ��﷨����</td>
 *			<td>ֻ��grammarʶ����Ч��ָ���﷨��ʽ��<br/>
 *				- id: ʹ���ƶ�Ԥ�õĻ��߱��ؼ��ص��﷨��Ž���ʶ��
 *				- wordlist: �� grammarData ���ݵ�����'\\r\\n'�����Ĵʱ����ʶ��
 *				- jsgf: �� grammarData ���ݵ����﷨�ļ�����ʶ���﷨�ļ���ʽ��μ�����ͨ����iSpeakGrammar�﷨����˵��.pdf��
 *				- wfst: ͨ��hci_asr_save_compiled_grammar�ӿڱ�����﷨�ļ���ֻ֧���ļ�����
 *			</td>
 *		</tr>
 *		<tr>
 *			<td>grammarId</td>
 *			<td>1</td>
 *			<td>��</td>
 *			<td>ʶ��ʹ�õ��﷨���</td>
 *			<td>ֻ��grammarʶ������grammarType����Ϊidʱ��Ч��<br/>
 *				- ��id�������ƶ�Ԥ�õ�ĳ���﷨Id��
 *				- Ҳ���������� hci_asr_load_grammar() ������õı��ص��﷨Id���������﷨Id�ֱ�����
 *				���ػ����ƶ˵��﷨ʶ������������֮��û�й�ϵ������ƽ̨ASR��ʶ��������Ԥ���﷨��������õ��﷨��ſ����ڿ���ʱ��ѯ��ͨ������</td>
 *		</tr>
 *		<tr>
 *			<td>isFile</td>
 *			<td>yes, no</td>
 *			<td>no</td>
 *			<td>����������ļ��������ڴ�����</td>
 *			<td>ֻ�Ա���grammarʶ����Ч��<br/>
 *			    - yes��ʾ����һ���﷨�ļ�����
 *				- no��ʾ��ֱ�����ڴ��е��﷨����
 *			</td>
 *		</tr>
 *		<tr>
 *			<td>domain</td>
 *			<td>music</td>
 *			<td>��</td>
 *			<td>ʶ��ʹ�õ�����</td>
 *			<td>ֻ��freetalkʶ������Ч��ʹ��ָ�������ģ�ͽ���ʶ��<br/>
 *				- ���capKey������δָ���ض�����, �����ʹ��domain���н�һ��ָ������
 *				- ���capKey�������Ѿ�ָ�����ض���������ʹ�ô����������ֻ��ʹ��һ�µ�����<br/>
 *				- �����ѡ��������õ���������ڿ���ʱ��ѯ��ͨ������</td>
 *		</tr>
 *		<tr>
 *			<td>addPunc</td>
 *			<td>yes, no</td>
 *			<td>no</td>
 *			<td>�Ƿ���ӱ��</td>
 *			<td>yes��ʾʶ���������ӱ�㣬no��ʾ����ӱ��</td>
 *		</tr>
 *		<tr>
 *			<td>candNum</td>
 *			<td>1-10</td>
 *			<td>10</td>
 *			<td>ʶ���ѡ�������</td>
 *			<td></td>
 *		</tr>
 *		<tr>
 *			<td>encode</td>
 *			<td>none, ulaw, alaw, speex,opus</td>
 *			<td>none</td>
 *			<td>ʹ�õı����ʽ</td>
 *			<td>ֻ���ƶ�ʶ����Ч���Դ�����������ݽ��б��봫�䡣<br/>
 *				- ����audioFormat��encode��ʹ�÷����μ��������ϸ˵����</td>
 *		</tr> 
 *		<tr>
 *			<td>encLevel</td>
 *			<td>0-10</td>
 *			<td>7</td>
 *			<td>ѹ���ȼ�</td>
 *			<td>ֻ���ƶ�ʶ����Ч��</td>
 *		</tr>
 *		<tr>
 *			<td>vadHead</td>
 *			<td>[0,30000]</td>
 *			<td>10000</td>
 *			<td>��ʼ�ľ�����������</td>
 *			<td>��������ʼ�ľ�����������ָ���ĺ�����ʱ����Ϊû�м�⵽����<br/>
 *				�����ֵΪ0�����ʾ�����������</td>
 *		</tr> 
 *		<tr>
 *			<td>vadTail</td>
 *			<td>[0,30000]</td>
 *			<td>500</td>
 *			<td>�˵����ĩβ������</td>
 *			<td>��⵽�����������ݳ��־������Ҿ���ʱ�䳬������ָ���ĺ�����ʱ����Ϊ��������<br/>
 *				�����ֵΪ0�����ʾ������ĩ�˼��</td>
 *		</tr>
 *		<tr>
 *			<td>vadSeg</td>
 *			<td>[0,30000]</td>
 *			<td>500</td>
 *			<td>�˵���ķֶμ��������</td>
 *			<td>Ŀǰֻ���ƶ�����˵ʵʱ����ģʽ��Ч��<br/>
 *				��⵽�����������ݳ��־������Ҿ���ʱ�䳬������ָ���ĺ�����ʱ����Ϊ��Ƶ���зֶ�<br/>
 *				�����ֵΪ0�����ô��ڵ���vadtail�����ʾ�����зֶ�</td>
 *		</tr>
 *		<tr>
 *			<td>intention</td>
 *			<td>poi</td>
 *			<td>��</td>
 *			<td>ʶ����ͼ</td>
 *			<td>�����ƶ�dialogʶ������Ч��<br/>
 *				- �ƶ�ʶ����Զ���ʶ����������ͼ������������json��ʽ����ͼ���������ȡֵ������Ϣ����ѯ��ͨ������˾</td>
 *		</tr>
 *		<tr>
 *			<td>needContent</td>
 *			<td>yes, no</td>
 *			<td>yes</td>
 *			<td>�Ƿ���Ҫ��ͼʶ������</td>
 *			<td>�����ƶ�dialogʶ������Ч��<br/>
 *				ָ���Ƿ���Ҫ��ͼʶ�����ݣ�����ͼʶ����ȡ��Ӧ�����ݻ�𰸡�</td>
 *		</tr>
 *	</table>
 * @n@n
*/ 

- (void)showWithConfig:(NSString*)recogConfig andGrammar:(NSString*)grammar;

@end





