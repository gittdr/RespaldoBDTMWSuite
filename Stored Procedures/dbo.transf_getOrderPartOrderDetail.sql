SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
 
CREATE PROCEDURE [dbo].[transf_getOrderPartOrderDetail] 
      (@ordnum varchar(12))
AS
 
set nocount on
      SELECT DISTINCT
            isnull(oh.ord_route, '') as ord_route
            , isnull(poh_supplier, '') as poh_supplier
			--, c.cmp_altid 
			, isnull((select c.cmp_altid 
				from company c 
					JOIN company_alternates ca ON c.cmp_id = ca_alt AND c.cmp_revtype1 = ph.poh_branch and ca_id = ph.poh_supplier
				),'') as cmp_altid
            --, c.cmp_name as supplier_name
			, isnull((select c.cmp_name 
				from company c 
					JOIN company_alternates ca ON c.cmp_id = ca_alt AND c.cmp_revtype1 = ph.poh_branch and ca_id = ph.poh_supplier
				),'') as supplier_name
			-- supplier city
			, isnull
			(
				(
					select ct.cty_nmstct from city ct
						join company c on c.cmp_city = ct.cty_code
						JOIN company_alternates ca ON c.cmp_id = ca_alt AND c.cmp_revtype1 = ph.poh_branch and ca_id = ph.poh_supplier
				),''
			) as supplier_city
			, isnull((select name from labelfile where labeldefinition='PartOrderStatus' and ph.poh_status=abbr and retired='N'), '') as poh_status
            , poh_refnum
            , pod_partnumber
			, pod_originalcount
            , pod_cur_count
      FROM partorder_header ph
            JOIN partorder_detail pd ON ph.poh_identity = pd.poh_identity
            JOIN partorder_routing pr ON ph.poh_identity = pr.poh_identity
            JOIN orderheader oh ON oh.ord_hdrnumber = pr.por_ordhdr
      WHERE oh.ord_number = @ordnum

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[transf_getOrderPartOrderDetail] TO [public]
GO
