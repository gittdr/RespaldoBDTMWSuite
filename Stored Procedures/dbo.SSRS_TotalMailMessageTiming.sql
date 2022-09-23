SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create Procedure [dbo].[SSRS_TotalMailMessageTiming]
(
@DateStart datetime,
@DateEnd datetime
)
/*
SSRS_TotalMailMessageTiming
9/2/2014 JR

Change Log:
 
*/
AS
declare @History int
set @History = (select top 1 convert(int,text) from tblrs where keycode='HISTORY')

select 
msg.SN as [MessageSN]
,msg.origmsgsn as [OriginalMessageSN]
,msg.dtsent as [Date Sent]
,msg.DTReceived as [Date Received]
,msg.DTRead as [Date Read]
,msg.DTTransferred as [Date Transferred]
,sta.Code as [Status Code]
,msg.Subject
,sta.description as [Status Description]
,msg.FromName as [From]
,isnull((select top 1 [Description] from tblAddressTypes adr with(nolock)  where adr.SN = msg.FromType),'') as [From Type]
,msg.DeliverTo as [Deliver to]
,isnull((select top 1 [Description] from tblAddressTypes adr  with(nolock) where adr.SN = msg.DeliverToType),'') as [Deliver to Type]
into #tempresults
from tblMessages msg with(nolock)
join tblMsgStatus sta  with(nolock) on msg.[Status] = sta.SN
WHERE
msg.folder= @History
and
msg.DTSent >=@DateStart and msg.DTSent < @DateEnd

	
select *,
case [From Type]
when 'Login' then 
	case [Deliver to Type]
	when 'Login' then 'Internal'
	else 'Outbound'
	end
else 'Inbound'
end as [Direction],

DATEDIFF(mi,[Date Sent],[Date Received])  as [Sent to Received],
DATEDIFF(mi,[Date Sent],[Date Transferred]) as [Sent to Transferred],
DATEDIFF(mi,[Date Sent],[Date Read]) as [Sent to Read],
DATEDIFF(mi,[Date Transferred],[Date Received]) as [Transferred to Received]
from #tempresults
order by [Date Sent] desc

GO
GRANT EXECUTE ON  [dbo].[SSRS_TotalMailMessageTiming] TO [public]
GO
