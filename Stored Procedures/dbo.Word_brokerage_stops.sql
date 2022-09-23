SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Still need to change this to be leg based.
create procedure [dbo].[Word_brokerage_stops]
@lgh_number varchar(10) 
as

Select
stops.stp_number,
company.cmp_name  stop_cmp_name,
cmp_primaryphone stop_cmp_phone,
cmp_Address1 stop_cmp_Address,
city.cty_nmstct stop_cty_nmstct,
stops.stp_schdtearliest,
stops.stp_schdtlatest,
stops.stp_arrivaldate,
stops.lgh_number,
stops.mfh_number,
stops.stp_type,
stops.stp_event,
stops.stp_sequence,
stops.trl_id,
stops.stp_mfh_sequence,
stops.stp_event,
stops.stp_ord_mileage,
stops.stp_lgh_mileage,
stops.stp_weight,
stops.stp_weightunit,
stops.cmd_code,
stops.stp_description,
stops.stp_count,
stops.stp_countunit,
stops.stp_comment,
stp_status,
stp_reftype,
stp_refnum,
stp_volume,
stp_volumeunit,
STP_DISPATCHED_SEQUENCE,
stp_arr_confirmed,
stp_dep_confirmed
from stops, city, Company
where
stops.lgh_number = @lgh_number and
stp_mfh_sequence > (select min(stp_mfh_sequence) from stops where lgh_number = @lgh_number) and
stp_mfh_sequence < (select max(stp_mfh_sequence) from stops where lgh_number = @lgh_number) and
stops.stp_city = cty_code and
stops.cmp_id = Company.cmp_id
order by stp_mfh_sequence
GO
GRANT EXECUTE ON  [dbo].[Word_brokerage_stops] TO [public]
GO
