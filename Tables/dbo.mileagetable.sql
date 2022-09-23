CREATE TABLE [dbo].[mileagetable]
(
[mt_type] [int] NOT NULL,
[mt_origintype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mt_origin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mt_destinationtype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mt_destination] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mt_miles] [float] NULL,
[mt_hours] [decimal] (6, 2) NULL,
[mt_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mt_updatedon] [datetime] NULL,
[timestamp] [timestamp] NULL,
[mt_verified] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mt_old_miles] [float] NULL,
[mt_source] [int] NULL,
[mt_Authorized] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mt_AuthorizedBy] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mt_AuthorizedDate] [datetime] NULL,
[mt_route] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mt_identity] [int] NOT NULL IDENTITY(1, 1),
[mt_haztype] [int] NULL,
[mt_tolls_cost] [money] NULL,
[mt_verified_date] [datetime] NULL,
[mt_lastused] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE trigger [dbo].[dt_mileagetable] on [dbo].[mileagetable] for delete
as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

/* Revision History:
	8/27/04 DPETE SR 22841
*/


-- Delete any state miles linked to this mileage table.
Delete From statemiles 
Where mt_identity in (Select mt_identity from deleted)

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[it_mileagetable] 
ON [dbo].[mileagetable]
FOR INSERT
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

/* log
DPETE 22841 converting mileagetable to hold city name not number for GI
   DistanceLookupVersio=2004
*/

If Not Exists (Select gi_string1 From generalinfo Where gi_name = 'DistanceLookupVersion'
  and Rtrim(gi_string1) = '2004')

  BEGIN

	-- KMM 31377, determine if values are numeric
	Declare @mt_origin_numeric		tinyint,
			@mt_destination_numeric	tinyint
	-- KMM END 31377

  /* PTS 4384 MF 8/10/98 This SQl will prevent the bad mileages from being entered
		into the mileage table.  Futhuire research is required to 
		see why they are being entered */

Select	@mt_origin_numeric = IsNumeric(mt_origin),
		@mt_destination_numeric = IsNumeric(mt_destination)
FROM	inserted

-- KMM 31377, If either origin or destination is NOT numeric, get out of the trigger (SQL 2005 requires check)
IF @mt_origin_numeric = 0 OR @mt_destination_numeric = 0
	Begin
 		RETURN
	END
-- KMM END 31377


-- PTS 34662 -- BL (start)
--     (comment out)
-- IF (select count(*) from inserted
--   	where mt_destinationtype = 'C' 
-- 	  and convert(int,mt_destination) = mt_miles) > 0
--   BEGIN
--      ROLLBACK TRANSACTION
--   END
--   ELSE
--   IF (select count(*) from inserted
-- 	  where mt_origintype = 'C' 
-- 	  and convert(int,mt_origin) = mt_miles) > 0
--   BEGIN
--      ROLLBACK TRANSACTION
--   END
-- PTS 34662 -- BL (end)
END


GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Autor Emolvera
version 1.0
fecha : 15 de jun 2019

*/

CREATE TRIGGER [dbo].[it_mileagetablereverse] 
ON [dbo].[mileagetable]
FOR INSERT
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 




  BEGIN
	
insert into mileagetable  ( mt_type, mt_origintype, mt_origin, mt_destinationtype, mt_destination, mt_miles, mt_hours, mt_updatedby, mt_updatedon, mt_verified, mt_old_miles, mt_source, mt_Authorized, 
                         mt_AuthorizedBy, mt_AuthorizedDate,  mt_haztype, mt_tolls_cost, mt_verified_date, mt_lastused)

 select 
mt_type,
mt_destinationtype,
mt_destination,
mt_origintype, 
mt_origin,
mt_miles,
mt_hours,
mt_updatedby,
mt_updatedon,
mt_verified,
mt_old_miles,
mt_source, 
mt_Authorized, 
mt_AuthorizedBy,
mt_AuthorizedDate,
mt_haztype,
mt_tolls_cost, 
mt_verified_date,
mt_lastused
    from inserted q
	where 
      (select count(*) from mileagetable m where m.mt_origin = q.mt_destination and m.mt_destination =  q.mt_destination and m.mt_type = q.mt_type) = 0 
	
	




END


GO
DISABLE TRIGGER [dbo].[it_mileagetablereverse] ON [dbo].[mileagetable]
GO
CREATE UNIQUE CLUSTERED INDEX [uk_mt_identity] ON [dbo].[mileagetable] ([mt_identity]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_mileagetable] ON [dbo].[mileagetable] ([mt_type], [mt_origintype], [mt_origin], [mt_destinationtype], [mt_destination], [mt_haztype]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[mileagetable] TO [public]
GO
GRANT INSERT ON  [dbo].[mileagetable] TO [public]
GO
GRANT REFERENCES ON  [dbo].[mileagetable] TO [public]
GO
GRANT SELECT ON  [dbo].[mileagetable] TO [public]
GO
GRANT UPDATE ON  [dbo].[mileagetable] TO [public]
GO
