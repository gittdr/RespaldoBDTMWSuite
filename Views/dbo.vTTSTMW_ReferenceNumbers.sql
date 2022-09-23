SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE   View [dbo].[vTTSTMW_ReferenceNumbers]

As

Select
	[ref_tablekey] as [Table Key],
	[ref_type] as [Ref Type],
	[ref_number] as [Ref Number],
	[ref_typedesc] as [Type Desc],
	[ref_sequence] as [Sequence],
	[ord_hdrnumber] as [Order Header Number],
	[ref_table] as [Table],
	[ref_sid] as [SID],
	[ref_pickup] as [Pickup]

From    ReferenceNumber (NOLOCK)










GO
GRANT SELECT ON  [dbo].[vTTSTMW_ReferenceNumbers] TO [public]
GO
