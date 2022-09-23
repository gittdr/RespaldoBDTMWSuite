SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[eta_clear_prev_results] @delete_eta_stops char (1) 
AS
SET NOCOUNT ON
declare @startdate datetime
select @startdate = dateadd ( hour , 24 , getdate ( ) )

IF @delete_eta_stops = 'Y'
	delete from stops_eta where lgh_number in 
	(
	select lgh_number 
	from legheader with (nolock)
	where lgh_etaalert1 in ( '1' , '2' , '3' ) and lgh_active <> 'Y'
	UNION
	select lgh_number 
	from legheader with (nolock)
	where lgh_etaalert1 in ( '1' , '2' , '3' ) and lgh_outstatus ='CMP'
	UNION
	select lgh_number 
	from legheader with (nolock)
	where lgh_etaalert1 in ( '1' , '2' , '3' ) and lgh_startdate >= @startdate
	UNION
	select lgh_number 
	from legheader with (nolock)
	where lgh_etaalert1 in ( '1' , '2' , '3' ) and ord_hdrnumber = 0 )

update legheader set lgh_etaalert1 = NULL where lgh_number in 
(
select lgh_number 
from legheader with (nolock)
where lgh_etaalert1 in ( '1' , '2' , '3' ) and lgh_active <> 'Y'
UNION
select lgh_number 
from legheader with (nolock)
where lgh_etaalert1 in ( '1' , '2' , '3' ) and lgh_outstatus ='CMP'
UNION
select lgh_number 
from legheader with (nolock)
where lgh_etaalert1 in ( '1' , '2' , '3' ) and lgh_startdate >= @startdate
UNION
select lgh_number 
from legheader with (nolock)
where lgh_etaalert1 in ( '1' , '2' , '3' ) and ord_hdrnumber = 0 ) 

GO
GRANT EXECUTE ON  [dbo].[eta_clear_prev_results] TO [public]
GO
