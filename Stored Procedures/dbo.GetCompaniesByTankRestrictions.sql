SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[GetCompaniesByTankRestrictions]
 @cmp_revtype1 varchar(6),
 @cmp_revtype2 varchar(6),
 @cmp_revtype3 varchar(6),
 @cmp_region1 varchar(6),
 @cmp_region2 varchar(6),
 @cmp_region3 varchar(6),
 @cmp_othertype1 varchar(6),
 @cmp_othertype2 varchar(6),
 @cmp_defaultbillto varchar(8),
 @cmp_InvSrvMode varchar(6),
 @cmp_bookingterminal varchar(8),
 @cmp_inv_controlling_cmp_id varchar(8)
AS

select	cmp_id 
from	company c
where	(ISNULL(@cmp_revtype1, 'UNK') = 'UNK' OR c.cmp_revtype1 = @cmp_revtype1) and
		(ISNULL(@cmp_revtype2, 'UNK') = 'UNK' OR c.cmp_revtype2 = @cmp_revtype2) and
		(ISNULL(@cmp_revtype3, 'UNK') = 'UNK' OR c.cmp_revtype3 = @cmp_revtype3) and
		(ISNULL(@cmp_region1, 'UNK') = 'UNK' OR c.cmp_region1 = @cmp_region1) and
		(ISNULL(@cmp_region2, 'UNK') = 'UNK' OR c.cmp_region2 = @cmp_region2) and
		(ISNULL(@cmp_region3, 'UNK') = 'UNK' OR c.cmp_region3 = @cmp_region3) and
		(ISNULL(@cmp_othertype1, 'UNK') = 'UNK' OR c.cmp_othertype1 = @cmp_othertype1) and
		(ISNULL(@cmp_othertype2, 'UNK') = 'UNK' OR c.cmp_othertype2 = @cmp_othertype2) and
		(ISNULL(@cmp_defaultbillto, 'UNKNOWN') = 'UNKNOWN' OR c.cmp_defaultbillto = @cmp_defaultbillto) and
		(ISNULL(@cmp_InvSrvMode, 'UNK') = 'UNK' OR c.cmp_InvSrvMode = @cmp_InvSrvMode) and
		(ISNULL(@cmp_bookingterminal, 'UNKNOWN') = 'UNKNOWN' OR c.cmp_bookingterminal = @cmp_bookingterminal) and
		(ISNULL(@cmp_inv_controlling_cmp_id, 'UNKNOWN') = 'UNKNOWN' OR c.cmp_inv_controlling_cmp_id = @cmp_inv_controlling_cmp_id) and
		c.cmp_active = 'Y'

GO
GRANT EXECUTE ON  [dbo].[GetCompaniesByTankRestrictions] TO [public]
GO
