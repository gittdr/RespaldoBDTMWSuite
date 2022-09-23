SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi_214_record_id_2_sp] 
	@cmp_id varchar( 8 ),
	@n101code varchar(2),
	@trpid varchar(20)
as
/**
 * 
 * NAME:
 * dbo.edi_214_record_id_2_sp 
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

declare @EDI214Ver varchar(60)
select @EDI214Ver=isnull(gi_string1,'1.0')
	from generalinfo
	where gi_name='EDI214Ver'

if @EDI214Ver='3.4'
-- version 3.4
exec edi_214_record_id_2_34_sp
	@cmp_id,
	@n101code,
	@trpid

else if @EDI214Ver='3.9'
-- version 3.9
exec edi_214_record_id_2_39_sp 
	@cmp_id,
	@n101code,
	@trpid
-- else if @EDI214Ver='3.2'
-- version 3.2 (not supported but here to demonstrate if -- else structure
-- exec edi_214_record_id_2_32_sp (same parameters)
else
-- either not specified, or version 1.0
exec edi_214_record_id_2_10_sp
	@cmp_id,
	@n101code,
	@trpid

GO
GRANT EXECUTE ON  [dbo].[edi_214_record_id_2_sp] TO [public]
GO
