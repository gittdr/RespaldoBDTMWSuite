SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[fix_labelfile_sp]

AS
/**
 * 
 * NAME:
 * dbo.fix_labelfile_sp
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * This procedure enforces the relationship between the TrcExp and TrcStatus sets
 * in the labelfile.  It coies (inserts) and rows in TrcStatus from TrcExp that
 * do not have an equivilant TrcStatus and updates rows in TrcStatus where the
 * abbr is the same but the code is different.
 * 
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001 -   
 * Calls002 -
 *
 * CalledBy001 -
 * CalledBy002 - 
 *
 * REVISION HISTORY:
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 *
 **/

Insert into labelfile
	(labeldefinition, name, abbr, code, locked, userlabelname, edicode, systemcode, retired) 
	select 'TrcStatus', name, abbr, code, locked, '', edicode, systemcode, retired
	from labelfile where
	labeldefinition='TrcExp' and
	code in
		(select a.code from labelfile a
		where a.labeldefinition='TrcExp'
		and (select count(*) from labelfile b where b.labeldefinition='TrcStatus'
		and a.code = b.code) = 0
		and (select count(*) from labelfile c where c.labeldefinition='TrcStatus'
		and a.abbr = c.abbr) = 0)

update a
	set a.code = b.code
	from labelfile a,labelfile b
	where a.labeldefinition = 'TrcStatus'
	and b.labeldefinition = 'TrcExp'
	and a.abbr = b.abbr and a.code <> b.code

GO
GRANT EXECUTE ON  [dbo].[fix_labelfile_sp] TO [public]
GO
