SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/**
 
NAME:
dbo.tmail_get_TrailerTypes

TYPE:
Stored Procedure

DESCRIPTION:
gathers Trailer Types, and other Classifications


Prams:
@IDList list of IDs to gather info for

Change Log: 
rwolfe init 2015/06/15
 **/

CREATE PROCEDURE [dbo].[tmail_get_TrailerTypes]
	@IDList as dbo.tmail_StringList READONLY
AS 
Begin

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

select T.trl_number as 'trl_number', t1.Val as 'Type1', t2.Val as 'Type2',t3.Val as 'Type3',t4.Val as 'Type4', ter.Val as 'Terminal', flt.Val as 'Fleet', div.Val as 'Division', cmp.Val as 'Company' from trailerprofile T 
	left join (select name as 'Val', abbr from labelfile where labeldefinition = 'trltype1') t1 on T.trl_type1 = t1.abbr		--begin excessive Joins
	left join (select name as 'Val', abbr from labelfile where labeldefinition = 'trltype2') t2 on T.trl_type2 = t2.abbr
	left join (select name as 'Val', abbr from labelfile where labeldefinition = 'trltype3') t3 on T.trl_type3 = t3.abbr
	left join (select name as 'Val', abbr from labelfile where labeldefinition = 'trltype4') t4 on T.trl_type4 = t4.abbr
	left join (select name as 'Val', abbr from labelfile where labeldefinition = 'Terminal') ter on T.trl_terminal = ter.abbr
	left join (select name as 'Val', abbr from labelfile where labeldefinition = 'Fleet') flt on T.trl_fleet = flt.abbr
	left join (select name as 'Val', abbr from labelfile where labeldefinition = 'Division') div on T.trl_division = div.abbr
	left join (select name as 'Val', abbr from labelfile where labeldefinition = 'Company') cmp on T.trl_company = cmp.abbr		--end Excessive Joins
where T.trl_number in (select Val from @IDList)

End
GO
GRANT EXECUTE ON  [dbo].[tmail_get_TrailerTypes] TO [public]
GO
