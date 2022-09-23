SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[eta2_clear_prev_results] 
AS
SET NOCOUNT ON
declare @startdate datetime
select @startdate = dateadd ( hour , 24 , getdate ( ) )

/* note: we need to leave stops_eta for work cycle */
update lgh_eta set lgh_etaalert1 = NULL where lgh_number in 
(
select l.lgh_number 
from lgh_eta le with (nolock) join legheader l with (nolock) on le.lgh_number = l.lgh_number
where le.lgh_etaalert1 in ( '1' , '2' , '3' ) and lgh_active <> 'Y'
UNION
select l.lgh_number 
from lgh_eta le with (nolock) join legheader l with (nolock) on le.lgh_number = l.lgh_number
where le.lgh_etaalert1 in ( '1' , '2' , '3' ) and lgh_outstatus ='CMP'
UNION
select l.lgh_number 
from lgh_eta le with (nolock) join legheader l with (nolock) on le.lgh_number = l.lgh_number
where le.lgh_etaalert1 in ( '1' , '2' , '3' ) and lgh_startdate >= @startdate
UNION
select l.lgh_number 
from lgh_eta le with (nolock) join legheader l with (nolock) on le.lgh_number = l.lgh_number
where le.lgh_etaalert1 in ( '1' , '2' , '3' ) and ord_hdrnumber = 0 ) 


GO
GRANT EXECUTE ON  [dbo].[eta2_clear_prev_results] TO [public]
GO
