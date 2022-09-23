SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE   View [dbo].[vSSRSRB_ReferenceNumbers]
As

/**
 *
 * NAME:
 * dbo.vSSRSRB_ReferenceNumbers
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Retrieve ReferenceNumber Data from ReferenceNumbers Table
 *
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 PJK Created 
 **/
 
Select
	[ref_tablekey]  as [Table Key],
	[ref_type]      as [Ref Type],
	[ref_number]    as [Ref Number],
	[ref_typedesc]  as [Type Desc],
	[ref_sequence]  as [Sequence],
	[ord_hdrnumber] as [Order Header Number],
	[ref_table]     as [Table],
	[ref_sid]       as [SID],
	[ref_pickup]    as [Pickup]

From  ReferenceNumber WITH (NOLOCK)

GO
GRANT SELECT ON  [dbo].[vSSRSRB_ReferenceNumbers] TO [public]
GO
