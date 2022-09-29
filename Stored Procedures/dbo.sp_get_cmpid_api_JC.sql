SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_get_cmpid_api_JC] (@order varchar(100))
AS
BEGIN
    select le.ord_hdrnumber as ord_hdrnumber, tr.trc_licnum as trc_licnum,co.cmp_id as cmp_id,cast(isnull(round(cast(co.cmp_latseconds as float)/3600,4),0.0) as varchar(20))as latitude,
cast(isnull(round(cast(co.cmp_longseconds as float)/3600,4)*-1,0.0) as varchar(20)) as longitude 
from stops st, legheader le , tractorprofile tr, company co,orderheader oh
where 
st.lgh_number = le.lgh_number and 
le.lgh_tractor = tr.trc_number and
st.cmp_id        = co.cmp_id and
oh.ord_hdrnumber = le.ord_hdrnumber and
oh.ord_extrainfo2 is null and
st.lgh_number in (
select lgh_number from legheader where lgh_outstatus = 'PLN' and lgh_createdon > '2022-09-25'
) and co.cmp_id = 'PORCONF' and le.ord_hdrnumber = @order 
GROUP BY le.ord_hdrnumber, tr.trc_licnum,co.cmp_id,co.cmp_latseconds,co.cmp_longseconds
order by le.ord_hdrnumber
END
GO
