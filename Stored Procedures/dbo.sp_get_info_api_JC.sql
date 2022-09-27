SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_get_info_api_JC] (@order varchar(100))
AS
BEGIN
    select le.ord_hdrnumber,le.lgh_tractor as lgh_tractor, tr.trc_licnum as trc_licnum, st.stp_mfh_sequence as stp_mfh_sequence, st.stp_number as stp_number,
format(st.stp_schdtearliest,'yyyy-MM-ddTHH:MM:ss')as startDateTime,
format(st.stp_schdtlatest,'yyyy-MM-ddTHH:MM:ss')as endDateTime,
co.cmp_zip as cmp_zip, co.cmp_address1 +' ' +isnull(co.cmp_address2,'')as addressLines,co.cty_nmstct as cty_nmstct, co.cmp_state as cmp_state, co.cmp_country as cmp_country,co.cmp_id as cmp_id,
cast(isnull(round(cast(co.cmp_latseconds as float)/3600,4),0.0) as varchar(20))as latitude,
cast(isnull(round(cast(co.cmp_longseconds as float)/3600,4)*-1,0.0) as varchar(20)) as longitude
from stops st, legheader le , tractorprofile tr, company co
where 
st.lgh_number = le.lgh_number and 
le.lgh_tractor = tr.trc_number and
st.cmp_id        = co.cmp_id and
st.lgh_number in (
select lgh_number from legheader where lgh_outstatus = 'PLN'
)and le.ord_hdrnumber = @order
order by le.ord_hdrnumber,st.stp_mfh_sequence
END

GO
