SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
 
CREATE PROCEDURE [dbo].[transf_rpt_getOrderChecksheetRotax] 
      (@ordnum varchar(12))
AS
 
set nocount on
      SELECT DISTINCT
            poh_refnum
            , isnull(oh.ord_route, '') as ord_route
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
            , poh_plant
            , p.cmp_name as plant_name
            , poh_pickupdate
            , (oh.ord_route + '-' + convert(varchar(6), poh_pickupdate, 12)) as M_code
            , poh_deliverdate
            , pod_cur_count
            , pod_countpercontainer
            , pod_partnumber
            , pod_uom -- container type
            , case poh_dock
					when 'RX' THEN '1000'
					else '5000'
				  end as 'poh_dock'
            , isnull(pod_xdock, '') as pod_xdock
            , poh_jittime
            , stops.stp_schdtearliest -- pickup window arrive
            , stops.stp_schdtlatest -- pickup window depart
            , pod_originalUOM
			   , deliverroute = isnull((SELECT ord_route FROM orderheader JOIN partorder_routing pord ON pord.por_ordhdr = orderheader.ord_hdrnumber AND ord_hdrnumber > 0
           		WHERE pord.poh_identity = ph.poh_identity AND pord.por_sequence = 
            	(SELECT MAX(porseq.por_sequence) FROM partorder_routing porseq WHERE porseq.poh_identity = ph.poh_identity)), '')
      FROM partorder_header ph
            JOIN partorder_detail pd ON ph.poh_identity = pd.poh_identity
            JOIN partorder_routing pr ON ph.poh_identity = pr.poh_identity
            JOIN orderheader oh ON oh.ord_hdrnumber = pr.por_ordhdr
            JOIN company s ON s.cmp_id = ph.poh_supplier
            JOIN company p ON p.cmp_id = ph.poh_plant
            JOIN stops ON stops.ord_hdrnumber = oh.ord_hdrnumber AND stops.cmp_id = por_origin
			--JOIN company_alternates ON ca_id = poh_supplier
			--JOIN company c ON c.cmp_id = ca_alt AND c.cmp_revtype1 = poh_branch
      WHERE oh.ord_number = @ordnum

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[transf_rpt_getOrderChecksheetRotax] TO [public]
GO
