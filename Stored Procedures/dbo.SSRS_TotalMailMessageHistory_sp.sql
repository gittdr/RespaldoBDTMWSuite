SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create Procedure [dbo].[SSRS_TotalMailMessageHistory_sp]
(
@DateStart datetime,
@DateEnd datetime,
@Folder varchar(255),
@Tractor varchar(8),
@Driver varchar(8),
@From varchar(100),
@To varchar(100),
@Form int,
@Errors int

)
/*
SSRS_TotalMailMessageHistory_sp
1/7/2013 Jerry Ritcey

Change Log:
 
*/
AS

select 
dbo.[fnc_SSRS_TotalMailFolderName](msg.Folder) as [Folder]
,msg.SN as [MessageSN]
,msg.origmsgsn as [OriginalMessageSN]
,msg.dtsent as [Date Sent]
,msg.DTReceived as [Date Received]
,msg.DTRead as [Date Read]
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
and
(trc.TruckName = @Tractor or @Tractor = 'All')
and 
(dr1.DispSysDriverID = @Driver or @Driver = 'All')
and 
(msg.FromName = @From or @From = 'All')
and 
(msg.DeliverTo = @To or @To = 'All')


select *
from #tempresults
where 
([Folder] = @Folder or @Folder = 'All')
and 
((([TotalMail Form ID] is not null or [TotalMail Form ID]<>0) and @Form =1) or @Form = 0)
and
((([Error Message] is not null) and @Errors = 1) or @Errors = 0)
order by [Folder],[Date Sent] desc

GO
GRANT EXECUTE ON  [dbo].[SSRS_TotalMailMessageHistory_sp] TO [public]
GO
