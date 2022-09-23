SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[d_sv_avail_retrieve2_sp] (@dc_value varchar(6),@load_type_value varchar(6)) -- revtype1 and revtype2 from the orderheader
as
SELECT	0, orderheader.mov_number,
		referencenumber.ref_number,
		orderheader.ord_originpoint,
		min(stp_arrivaldate) as stp_arrivaldate,
		orderheader.ord_destpoint,
		max(ISNULL(ord_totalweight,0)) as fgt_weight,   --using max just because we do not want to group
		max(ISNULL(ord_totalvolume,0)) as fgt_volume ,  --by these fields so we need an aggregate function
		orderheader.sv_manu_export_flag
FROM 	stops with(nolock),
		referencenumber with(nolock),
		orderheader with(nolock)

WHERE   ( orderheader.ord_status = 'AVL' ) AND
		( orderheader.ord_completiondate > dateadd(dd, -30, getdate())) AND

		( orderheader.ord_revtype1 = @dc_value ) AND
		( orderheader.ord_revtype2 = @load_type_value )  AND
		( stops.mov_number = orderheader.mov_number ) AND
		( referencenumber.ref_tablekey = orderheader.ord_hdrnumber ) AND
		( referencenumber.ref_type = 'MRS' or referencenumber.ref_type = 'BGI' ) AND
		( referencenumber.ref_table = 'orderheader' )
GROUP BY	orderheader.mov_number,
			orderheader.ord_originpoint,
			orderheader.ord_destpoint,
			referencenumber.ref_number,
			orderheader.sv_manu_export_flag
ORDER BY    orderheader.mov_number

GO
GRANT EXECUTE ON  [dbo].[d_sv_avail_retrieve2_sp] TO [public]
GO
