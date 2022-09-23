SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
Returns arrival dates and times 
PTS 55342 SGB 
*/

CREATE PROC [dbo].[D_STOPSBOLTIMES_SP] (@ord_hdrnumber int)


AS

SELECT 
s.stp_event, 
s.cmp_id, 
s.cmp_name, 
s.stp_arrivaldate, 
isnull(bol.bol_arrivaldate,'1950-01-01') as bol_arrivaldate,
s.stp_status, 
s.stp_departuredate, 
isnull(bol.bol_departuredate,'2049-12-31') as bol_departuredate,
s.stp_departure_status,
bol.stp_number as stp_number,
s.stp_number as stop_stp_number

FROM stops s
LEFT OUTER JOIN stops_bol_dates bol 
ON bol.stp_number = s.stp_number
WHERE s.ord_hdrnumber =@ord_hdrnumber 
order by s.stp_sequence
GO
GRANT EXECUTE ON  [dbo].[D_STOPSBOLTIMES_SP] TO [public]
GO
