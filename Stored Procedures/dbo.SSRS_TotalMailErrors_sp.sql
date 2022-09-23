SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create Procedure [dbo].[SSRS_TotalMailErrors_sp]
(
@DateStart datetime,
@DateEnd datetime
)
/*
SSRS_TotalMailErrors_sp
10/22/2014

Example call

exec [SSRS_TotalMailErrors_sp] @DateStart = '10/1/2014',@DateEnd='10/15/2014'
Change Log:
 
*/
AS
DECLARE @HistoryFolder int

set @HistoryFolder = (select top 1 convert(int,t.[text]) from tblrs t with (nolock)
	where keyCode = 'History')

select 
dbo.[fnc_SSRS_TotalMailFolderName](msg.Folder) as [Folder]
,msg.SN as [MessageSN]
,msg.origmsgsn as [OriginalMessageSN]
,msg.dtsent as [Date Sent]
,msg.DTReceived as [Date Received]
,msg.DTRead as [Date Read]
,msg.ResubmitOf as [Resubmit]
,sta.Code as [Status Code]
,(select top 1 sta.[Description] from tblMsgStatus sta where msg.[Status] = sta.SN) as [Status Description]
,msg.Receipt as [Read Receipt]
 ,ISNULL((select top 1 readbyname from tblmsgsharedata d where  d.origmsgsn=msg.origmsgsn),'') as [Read by]
,pri.[Description] as [Message Priority]
,msg.FromName as [From]
,isnull((select top 1 [Description] from tblAddressTypes adr where adr.SN = msg.FromType),'') as [From Type]
,msg.DeliverTo as [Deliver to]
,isnull((select top 1 [Description] from tblAddressTypes adr where adr.SN = msg.DeliverToType),'') as [Deliver to Type]
,isnull(frm.Name,'') as [Form Name]
,frm.FormID as [TotalMail Form ID]
,sel.ID as [Mobile Comm Form ID]
,msg.[Subject] as [Subject]
,sha.MsgImage as [Message]
,isnull(err.[Description],'') as [Error Message]
,trc.TruckName as [Tractor]
,dr1.DispSysDriverID as [Driver ID]
,msg.DTPosition as [GPS Date]
,msg.Latitude as [Latitude]
,msg.Longitude as [Longitude]
,LTRIM(RTRIM(right(replace(replace(convert(varchar(max),isnull(err.[Description],'')),char(10),''),char(13),''),120))) as [ErrorShort]

into #tempresults
from tblMessages msg
join tblMsgStatus sta on msg.[Status] = sta.SN
join tblMsgPriority pri on msg.[Priority] = pri.SN
left outer join tblMsgShareData sha on msg.BaseSN = sha.OrigMsgSN
join tblmsgproperties pro (nolock) on msg.sn=pro.msgsn 
join tblPropertyTypes pty on pro.PropSN = pty.SN	
left outer join tblForms frm on pro.Value = frm.SN and pty.propertyname ='Form'
left outer join  tblselectedmobilecomm sel on sel.formsn=frm.sn	
left outer join tblerrordata err (nolock) on pro.value=err.errlistid and pro.propsn=6
left outer join tblTrucks trc on msg.HistTrk = trc.sn
left outer join tblDrivers dr1 on msg.HistDrv = dr1.SN
WHERE
msg.DTSent >=@DateStart and msg.DTSent < @DateEnd



select 
*,
case LEN([ErrorShort])
when 0 then 0 
else 1
end  as [ErrorCount]
from #tempresults
order by [Folder],[Date Sent] desc

GO
GRANT EXECUTE ON  [dbo].[SSRS_TotalMailErrors_sp] TO [public]
GO
