












<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	
<style>
body, html{
				width: 100%;
				height: 100%;
}
</style>	
<div class="middlewap">
	<div class="middlewapleftpart">
		<div class="middlewapleftup">
			<div class="middletopt l">
				<div class="middletopttx">
			
			
				
					<div class="circle-80531 zp" style="background-image:url(/jsxsd/grxx/xszpLoad)">

					</div>
				
				
			
			</div>
			
			<div class="middletopttxl">
						<!--<img src="/jsxsd/grxx/xszpLoad"
							width="100" height="100" border="0" style="height:inherit;width:40px;"
							onerror="javasript:this.src='student/images/tx1.png';" />-->
					<div class="middletopttxlr">
						<div><div class="f14 blue middletopdwxxtit">&nbsp;</div><div class="middletopdwxxcont">&nbsp;</div></div>
						<div><div class="f14 blue middletopdwxxtit">学生姓名：</div><div class="middletopdwxxcont">宋志鹏</div></div>
						<div><div class="f14 blue middletopdwxxtit">学生编号：</div><div class="middletopdwxxcont">2024413493</div></div>
						<div><div class="f14 blue middletopdwxxtit">所属院系：</div><div class="middletopdwxxcont">网络空间安全学院</div></div>
						<div><div class="f14 blue middletopdwxxtit">专业名称：</div><div class="middletopdwxxcont">软件工程</div></div>
						<div><div class="f14 blue middletopdwxxtit">班级名称：</div><div class="middletopdwxxcont">24软工3班</div></div>
						
					</div>
				</div>
		</div>

		
		<script type="text/javascript"
			src="/jsxsd/js/jquery-min.js"
			language="javascript"></script>
		<script type="text/javascript"
			src="/jsxsd/js/common.js"
			language="javascript"></script>
		<script type="text/javascript"
			src="/jsxsd/js/iepngfix_tilebg.js"
			language="javascript"></script>
		
		<link rel="stylesheet" type="text/css" href="/jsxsd/js/My97DatePicker/skin/WdatePicker.css" />
		<link rel="stylesheet" type="text/css" href="/jsxsd/bootstrap/css/bootstrap.min.css" />
		<link type="text/css" rel="stylesheet" href="/jsxsd/framework/student/css/css.css"/>
		<link rel="stylesheet" type="text/css" href="/jsxsd/css/style.css"/>
		<link rel="stylesheet" type="text/css" href="/jsxsd/js/My97DatePicker/skin/WdatePicker.css" />
		<link
			href="/jsxsd/framework/images/common.css"
			rel="stylesheet" type="text/css" />

		<script type="text/javascript"
			src="/jsxsd/framework/student/js/ui.js"></script>
		<script type="text/javascript"
			src="/jsxsd/framework/student/js/laydate/laydate.js"></script>
		<script type="text/javascript"
			src="/jsxsd/framework/student/js/index.js"></script>
		<script type="text/javascript" src="/jsxsd/js/My97DatePicker/WdatePicker.js"></script>
		<div class="middletop">
			<div class="noticetitle b">
							我的课表
			</div>
			<div class="middletopleft">
				<div class="middletopleftkb">
					<div class="middletopleftl" style="height: 100%;">
						
						<div class="middletopleftrqbox" style="height: 12%;">
							<div class=" pr5 middletopleftzc" id="li_showWeek">
								
								<span class="main_text main_color">第19周</span>/20周
								
							</div>
							<div class="middletopleftdqrq">
								<input type="text" id="rq" value="2026-01-09" readonly class="form-control" placeholder="2026-01-09">
								<span class="input-group-addon" id="sizing-addon1" onclick="selectWdatePicker()">
									<i class="glyphicon glyphicon-calendar"></i>
								</span>
							</div>
							<div class="middletopleftdqrq" style="margin-left: 30px;color: black;">
								时间模式：<select name="sjms" id ="sjms" style="width:120px" onchange="selectWdatePicker2()">
								
									<option  value="94786EE0ABE2D3B2E0531E64A8C09931">默认节次模式</option>
								
							</select>
							</div>
						</div>
						
						<div id="kbLoading" style="height: 88%;overflow: auto;">
								
						</div>
						<script type="text/javascript">
							var sjms = document.getElementById("sjms");
							var sjmsValue = "";
							if(sjms){
								sjmsValue = sjms.value;
							}							
							//TD:67812 缴费课表控制
							var isjfkz = '0';
							if(isjfkz=="1"){
								$("#kbLoading").load("/jsxsd/view/xssf/xsjf_message.jsp", {rq: "2026-01-09"});
							}else{								
								$("#kbLoading").load("/jsxsd/framework/main_index_loadkb.jsp", {rq: "2026-01-09",sjmsValue:sjmsValue});
							}						
						</script>
					</div>
				</div>
			</div>
		</div>
		</div>
		<div class="middlewapleftdown">
			<div class="middlewapmyexam l">
				<div class="noticetitle b" style="height: 10%;">
					在线问答
				</div>
				<div class="examlist" style="height: 40%;">
					<ul class="list-group list_tz" style="margin-bottom:0;">
						  
					</ul>
				</div>
				<div class="noticetitle b" style="height: 10%;">
					学业信息
				</div>
				
					<div class="examlist" id="ul_xyxxggList" style="height: 40%;">
					</div>
				
			</div>
			<div class="middlewapmynotice">
				<div class="noticetitle b" style="height: 10%;">
					通知
				</div>
				<div class="noticelist" id="ul_tzggList">
					
				</div>
			</div>
		</div>
	</div>
	<div class="middlewaprightpart r">
		<div class="middlewaprightup" style="height: 52%;">
			<div class="noticetitle b">
				常用操作
			</div>
			<div class="usuafunmenu">
				<div class="panel-body" >
					<div class="cy_icon">
						
							<div class="grid"
								onclick="kjcdShow('NEW_XSD_PYGL','NEW_XSD_PYGL_WDKB','NEW_XSD_PYGL_WDKB_XQLLKB','/xskb/xskb_list.do','学期理论课表')">
								<div class="grid__icon">
									<img src="/jsxsd/framework/teacher/images/tb12.png"/>
								</div>
								<p class="grid__label" style="margin-top: 10px;">
									学期理论课表
								</p>
							</div>
					   
							<div class="grid"
								onclick="kjcdShow('NEW_XSD_XJCJ','NEW_XSD_XJCJ_WDCJ','NEW_XSD_XJCJ_WDCJ_KCCJCX','/kscj/cjcx_frm','课程成绩查询')">
								<div class="grid__icon">
									<img src="/jsxsd/framework/teacher/images/tb11.png"/>
								</div>
								<p class="grid__label" style="margin-top: 10px;">
									课程成绩查询
								</p>
							</div>
					   
							<div class="grid"
								onclick="kjcdShow('NEW_XSD_PYGL','NEW_XSD_PYGL_XKGL','NEW_XSD_PYGL_XKGL_NXSXKZX','/xsxk/xklc_list','学生选课中心')">
								<div class="grid__icon">
									<img src="/jsxsd/framework/teacher/images/tb9.png"/>
								</div>
								<p class="grid__label" style="margin-top: 10px;">
									学生选课中心
								</p>
							</div>
					   
							<div class="grid"
								onclick="kjcdShow('NEW_XSD_KSBM','NEW_XSD_KSBM_WDKS','NEW_XSD_KSBM_WDKS_KSAPCX','/xsks/xsksap_query','考试安排查询')">
								<div class="grid__icon">
									<img src="/jsxsd/framework/teacher/images/tb12.png"/>
								</div>
								<p class="grid__label" style="margin-top: 10px;">
									考试安排查询
								</p>
							</div>
					   
							<div class="grid"
								onclick="kjcdShow('NEW_XSD_JXPJ','NEW_XSD_JXPJ_JXPJ','NEW_XSD_JXPJ_JXPJ_XSPJ','/xspj/xspj_find.do','学生评价')">
								<div class="grid__icon">
									<img src="/jsxsd/framework/teacher/images/tb11.png"/>
								</div>
								<p class="grid__label" style="margin-top: 10px;">
									学生评价
								</p>
							</div>
					   
							<div class="grid"
								onclick="kjcdShow('NEW_XSD_KSBM','NEW_XSD_KSBM_WDSQ','NEW_XSD_KSBM_WDSQ_HKSQ','/kscj/hksq_query','缓考申请')">
								<div class="grid__icon">
									<img src="/jsxsd/framework/teacher/images/tb14.png"/>
								</div>
								<p class="grid__label" style="margin-top: 10px;">
									缓考申请
								</p>
							</div>
					   
							<div class="grid"
								onclick="kjcdShow('NEW_XSD_KSBM','NEW_XSD_KSBM_CJGL','NEW_XSD_KSBM_CJGL_SHKSBM','/xsdjks/xsdjks_list','社会考试报名')">
								<div class="grid__icon">
									<img src="/jsxsd/framework/teacher/images/tb12.png"/>
								</div>
								<p class="grid__label" style="margin-top: 10px;">
									社会考试报名
								</p>
							</div>
					   
							<div class="grid"
								onclick="kjcdShow('NEW_XSD_PYGL','NEW_XSD_PYGL_PYFA','NEW_XSD_PYGL_PYFAMX','/pyfa/topyfamx','培养方案明细')">
								<div class="grid__icon">
									<img src="/jsxsd/framework/teacher/images/tb11.png"/>
								</div>
								<p class="grid__label" style="margin-top: 10px;">
									培养方案明细
								</p>
							</div>
					   
					</div>
					
				</div>
			</div>
		</div>
		<div class="middlewaprightdown" style="height: 47.2%;">
			<div class="noticetitle b" style="height: 10%;">
				学期进度安排
			</div>
			<div class="noticelist">
				<ul class="cbp_tmtimeline" >
					
						<li>
							
							
								<div class="cbp_tmicon cbp_tmicon-phone" >一月</div>
							
							<div class="cbp_tmlabel">
					            <h6></h6>
					        </div>
						</li>
					
						<li>
							
								<div class="cbp_tmicon cbp_tmicon-phone" style="background-color:#1C84C6; " >十二月</div>
							
							
							<div class="cbp_tmlabel">
					            <h6></h6>
					        </div>
						</li>
					
						<li>
							
							
								<div class="cbp_tmicon cbp_tmicon-phone" >十一月</div>
							
							<div class="cbp_tmlabel">
					            <h6></h6>
					        </div>
						</li>
					
						<li>
							
								<div class="cbp_tmicon cbp_tmicon-phone" style="background-color:#1C84C6; " >十月</div>
							
							
							<div class="cbp_tmlabel">
					            <h6></h6>
					        </div>
						</li>
					
						<li>
							
							
								<div class="cbp_tmicon cbp_tmicon-phone" >九月</div>
							
							<div class="cbp_tmlabel">
					            <h6></h6>
					        </div>
						</li>
					
				</ul>
			</div>
		</div>
	</div>
</div>
	<!-- 侧边条 -->
	
	</body>
<script type="text/javascript"
	src="/jsxsd/js/jquery.messager.js"
	language="javascript"></script>
<script type="text/javascript">
function loadingTzgg() {
	$("#ul_tzggList").load("/jsxsd/framework/main_index_loadtzgg.jsp");
}
function loadingXyxxgg() {
	$("#ul_xyxxggList").load("/jsxsd/framework/main_index_loadxyxxgg.jsp");
}
function loadingXsCf() {
	$("#ul_XsCfList").load("/jsxsd/framework/main_index_XsCf.jsp");
}
$(function(){
	loadingTzgg();
	loadingXyxxgg();
	loadingXsCf();
	var  xxdm = 10446;
	var  pjs = 0;
	if (xxdm !=null && xxdm != "" && xxdm == "13933"  &&  pjs == 1){
		gotoTzgg1('xspj');
	}

});

var msg = "";
function selectWdatePicker() {
	var sjms = document.getElementById("sjms");
	var sjmsValue = "";
	if(sjms){
		sjmsValue = sjms.value;
	}
	WdatePicker({
		el:$dp.$("rq"),
		isShowClear:false,
		readOnly:true,
		onpicking: function(dq){
			$("#kbLoading").html("疯狂加载中...");
			if(isjfkz=="1"){
				$("#kbLoading").load("/jsxsd/view/xssf/xsjf_message.jsp", {rq: "2026-01-09"});
			}else{
				$("#kbLoading").load("/jsxsd/framework/main_index_loadkb.jsp", {rq: dq.cal.getNewDateStr()});			}
		}
	});
}

function kjcdShow(yjcode, ejcode, sjcode, url, name){
	parent.showMenuErji(parent.$(".cy_icon > li[data-code='"+yjcode+"']").get(0));
	parent.$(".sidebar-menu > li[data-code='"+ejcode+"']").addClass("active");
	parent.$(".sidebar-menu > li[data-code='"+ejcode+"']").find(".treeview-menu").show();
	parent.$(".sidebar-menu > li[data-code='"+ejcode+"']").find(".treeview-menu > li[data-sjcode='"+sjcode+"']").addClass("active");
	parent.$(".tabs li.tabs-selected").find(".tabs-title").text(name);
	parent.$("#Frame"+(parent.frameIndex-1)).attr("src", "/jsxsd"+url);
}

</script>
<script language="javascript">
function gotoZxwd(oaid) {
	top.artDialog({
		id: oaid,
		title: "在线问答",
		fixed: true,
		url: "/jsxsd/zxwd/zxwd_show?openType=art&oaid="+oaid,
		lock: true,
		width: $(window).width() - 200,
		height: $(window).height() - 100
	});
}

var old_td = "";
function gotoTzgg(ggid) {
	top.artDialog({
		id: ggid,
		title: "通知公告",
		fixed: true,
		url: "/jsxsd/framework/main_index_tzgg.jsp?id="+ggid,
		lock: true,
		width: $(window).width() - 200,
		height: $(window).height() - 300
	}, null, null, function(){
		loadingTzgg();
	});
}
function gotoTzgg1(ggid) {
	top.artDialog({
		id: ggid,
		title: "通知公告",
		fixed: false,
		url: "/jsxsd/framework/main_index_xspj.jsp?id="+ggid,
		lock: false,
		top : $(window).height()  -300,
		left:	$(window).width() +150,
		width: $(window).width()-900,
		height: $(window).height() - 300
	}, null, null, function(){

	});
}

function gotoXyxxgg(ggid) {
	top.artDialog({
		id: ggid,
		title: "学业信息",
		fixed: true,
		url: "/jsxsd/framework/main_index_xyxxgg.jsp?id="+ggid,
		lock: true,
		width: $(window).width() - 200,
		height: $(window).height() - 300
	}, null, null, function(){
		loadingXyxxgg();
	});
}

function gotoXyxxgg_txk(ggid,ywid) {
	top.artDialog({
		id: ggid,
		ywid: ywid,
		title: "学业信息",
		fixed: true,
		url: "/jsxsd/framework/main_index_xyxxgg_txk.jsp?id="+ggid+"&ywid="+ywid,
		lock: true,
		width: $(window).width() - 200,
		height: $(window).height() - 300
	}, null, null, function(){
		loadingXyxxgg();
	});
}

function gotoXyxxgg2(ggid) {
	top.artDialog({
		id: ggid,
		title: "修读信息",
		fixed: true,
		url: "/jsxsd/framework/main_index_xyxxgg2.jsp?id="+ggid,
		lock: true,
		width: $(window).width() - 200,
		height: $(window).height() - 100
	}, null, null, function(){
		loadingXyxxgg();
	});
}

function gotoXsCf(ggid) {
	top.artDialog({
		id: ggid,
		title: "学生处分信息",
		fixed: true,
		url: "/jsxsd/framework/main_index_XsCf.jsp?id="+ggid,
		lock: true,
		width: $(window).width() - 200,
		height: $(window).height() - 100
	}, null, null, function(){
		loadingXsCf();
	});
}

function showDetails(td_id,jx0408id){
	var oldtd = document.getElementById(old_td);
	if(oldtd!=null){
		oldtd.className="";
	}
	old_td = td_id;
	var td = document.getElementById(td_id);
	td.className = "act";
	
	$.ajax({
		type: "GET",
		 async:true,
		url: "/jsxsd/portal/queryDetails.do",
		data: {id:jx0408id,sjjc:td_id,zc:'19'},
		dataType: "json",
		success:function(data){
			var json = data.dataList[0];
			var kcmc = json.kcmc;
			if(kcmc.length>15){
				kcmc = kcmc.substr(0, 13)+"......";
			}
			document.getElementById("kcmc").innerText = kcmc;
			document.getElementById("xf").innerText = json.xf;
			document.getElementById("skjs").innerText = json.skjs;
			document.getElementById("skjs").innerText = "老师："+(json.skjs==null?"":json.skjs);
			document.getElementById("jsmc").innerText = "教室："+json.jsmc;
			document.getElementById("kkzc").innerText = "周次："+json.kkzc;
			document.getElementById("bz").innerText = "备注："+(json.bz==null?"":json.bz);
			document.getElementById("kcjd").innerText = data.jctxt;
			document.getElementById("kcjdt").style.width = data.bl + "%";
		}
	});
}

//置顶功能开始

function tzMouseout(ind){
	$("#fbsj"+ind).show();
	$("#img"+ind).hide();
}
function tzMouseover(ind){
	$("#fbsj"+ind).hide();
	$("#img"+ind).show();
}
function zdOper(obj,ggid){
	var parentsLi = $(obj).parent().parent().parent();//获得最顶层li控件
	var next = parentsLi.prev();//获得li的上一个兄弟节点
	
	while(next.prev().html() != undefined){
		next = next.prev();//获得li的上一个兄弟节点
	}
	next.fadeOut("slow",function(){//交换位置
		$(this).before(parentsLi);
		}).fadeIn();
	dwrMonitor.gglyZd(ggid);//更新置顶字段	
}
//置顶功能结束

//是否通过快速链接进入 1为是
var jumpFlag = "";
if("1" == jumpFlag){
	kjcdShow("", "", "" , "" ,"" );
}
function selectWdatePicker2() {
	var sjms = document.getElementById("sjms");
	var sjmsValue = "";
	if(sjms){
		sjmsValue = sjms.value;
	}
	var rq = document.getElementById("rq").value;
	$("#kbLoading").html("疯狂加载中...");
	$("#kbLoading").load("/jsxsd/framework/main_index_loadkb.jsp", {rq: rq,sjmsValue:sjmsValue});
}

</script>