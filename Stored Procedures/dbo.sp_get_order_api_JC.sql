SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_get_order_api_JC] 
AS
BEGIN
    select le.ord_hdrnumber as ord_hdrnumber,le.lgh_tractor as lgh_tractor, tr.trc_licnum as trc_licnum from stops st, legheader le , tractorprofile tr, company co
where 
st.lgh_number = le.lgh_number and 
le.lgh_tractor = tr.trc_number and
st.cmp_id        = co.cmp_id and
st.lgh_number in (
select lgh_number from legheader where lgh_outstatus = 'PLN'
)
GROUP BY le.ord_hdrnumber,le.lgh_tractor, tr.trc_licnum
order by le.ord_hdrnumber
END

GO
