SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[tmail_FindFAOpenLegs]

as

SET NOCOUNT ON 

create table #OpenCompletedLghs (lgh_Number int not null, lgh_startdate datetime)

insert into #OpenCompletedLghs (lgh_number, lgh_startdate)

SELECT l.lgh_number, l.lgh_startdate 
FROM legheader l (NOLOCK) 
WHERE --l.lgh_startdate > dateadd(mm, -1, getdate())  AND
l.lgh_outstatus = 'CMP' 
AND l.lgh_enddate >= dateadd(day, -3, getdate()) 
AND l.lgh_enddate <= dateadd(day, 3, getdate())
delete from #OpenCompletedLghs
from #OpenCompletedLghs
inner join stops s on #OpenCompletedLghs.lgh_number = s.lgh_number 
and s.stp_mfh_sequence = (select max(s2.stp_mfh_sequence) 
							from stops s2 (NOLOCK)
							where s2.lgh_number = #OpenCompletedLghs.lgh_number)
where ISNULL(s.stp_departure_status, 'OPN') = 'DNE'

(SELECT l.lgh_number, l.lgh_startdate 
FROM legheader l (NOLOCK)
WHERE --l.lgh_startdate > dateadd(mm, -1, getdate()) and 
(l.lgh_outstatus IN ('AVL', 'PLN', 'DSP', 'STD')))
UNION
(SELECT lgh_Number, lgh_startdate 
from #OpenCompletedLghs)
--drop table #OpenCompletedLghsd

GO
GRANT EXECUTE ON  [dbo].[tmail_FindFAOpenLegs] TO [public]
GO
