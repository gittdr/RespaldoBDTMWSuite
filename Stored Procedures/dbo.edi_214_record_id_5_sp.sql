SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi_214_record_id_5_sp] 
	@invoice_number varchar( 12 ),
	@trpid varchar(20)
AS
/**
 * 
 * NAME:
 * dbo.edi_214_record_id_5_sp 
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
exec edi_214_record_id_5_34_sp @invoice_number, @trpid
-- else if @EDI214Ver='3.3'
-- version 3.3 (not supported but here to demonstrate if -- else structure
-- exec edi_214_record_id_5_33_sp @invoice_number, @trpid
-- else if @EDI214Ver='3.2'
-- version 3.2 (not supported but here to demonstrate if -- else structure
-- exec edi_214_record_id_5_32_sp @invoice_number, @trpid
else
-- either not specified, or version 1.0
exec edi_214_record_id_5_10_sp @invoice_number, @trpid



GO
GRANT EXECUTE ON  [dbo].[edi_214_record_id_5_sp] TO [public]
GO
