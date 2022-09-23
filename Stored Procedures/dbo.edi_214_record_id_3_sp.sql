SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi_214_record_id_3_sp] 
@StatusCode varchar(2),
@StatusDateTime datetime,
@TimeZone varchar(2),
@StatusCity integer,
@TractorID varchar(13),
@MCUnitNumber int,
@TrailerOwner varchar(4),
@Trailerid varchar(13),
@StatusReason varchar(3),
@StopNumber varchar(3),
@StopWeight integer,
@StopQuantity integer,
@StopReferenceNumber varchar(15),
@ordhdrnumber integer
 as
/**
 * 
 * NAME:
 * dbo.edi_214_record_id_3_sp 
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
exec edi_214_record_id_3_34_sp @StatusCode,
@StatusDateTime,
@TimeZone,
@StatusCity,
@TractorID,
@MCUnitNumber,
@TrailerOwner,
@Trailerid,
@StatusReason,
@StopNumber,
@StopWeight,
@StopQuantity,
@StopReferenceNumber,
@ordhdrnumber

-- else if @EDI214Ver='3.3'
-- version 3.3 (not supported but here to demonstrate if -- else structure
-- exec edi_214_record_id_3_33_sp (same parameters)
-- else if @EDI214Ver='3.2'
-- version 3.2 (not supported but here to demonstrate if -- else structure
-- exec edi_214_record_id_3_32_sp (same parameters)
else
-- either not specified, or version 1.0
exec edi_214_record_id_3_10_sp @StatusCode,
@StatusDateTime,
@TimeZone,
@StatusCity,
@TractorID,
@MCUnitNumber,
@TrailerOwner,
@Trailerid,
@StatusReason,
@StopNumber,
@StopWeight,
@StopQuantity,
@StopReferenceNumber,
@ordhdrnumber

GO
GRANT EXECUTE ON  [dbo].[edi_214_record_id_3_sp] TO [public]
GO
