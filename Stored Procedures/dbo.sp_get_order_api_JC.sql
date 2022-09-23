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
select lgh_number from legheader where lgh_outstatus = 'PLN' and 
lgh_tractor in ('1601','1766','1774','1789','1790','1791','1792','1793','1794','1795','1796','1797','1799','1800','1801','1759','1854','1602','1762','1852','1848','1846','1853','1768')
)
GROUP BY le.ord_hdrnumber,le.lgh_tractor, tr.trc_licnum
order by le.ord_hdrnumber
END

GO
