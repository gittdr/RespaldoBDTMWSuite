SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi_214_version_sp] 
	@ord_number char(12)

 as
/**
 * 
 * NAME:
 * dbo.edi_214_version_sp 
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
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

exec prepare_for_edi_extract_sp

declare @EDI214Ver varchar(60)
select @EDI214Ver=isnull(gi_string1,'1.0')
	from generalinfo
	where gi_name='EDI214Ver'

if @EDI214Ver='3.4' -- version 3.4
	exec edi_214_record_id_1_34_sp @ord_number
else if @EDI214Ver='3.9' -- version 3.9
	exec edi_214_record_id_1_39_sp @ord_number
--else if @EDI214Ver='4.0' -- version 4.0
--	exec edi_214_record_id_1_40_sp @ord_number
else -- either not specified, or version 1.0
	exec edi_214_record_id_1_sp @ord_number

GO
GRANT EXECUTE ON  [dbo].[edi_214_version_sp] TO [public]
GO
