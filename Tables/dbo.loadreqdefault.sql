CREATE TABLE [dbo].[loadreqdefault]
(
[def_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[def_id_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[def_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[def_not] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[def_manditory] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[def_quantity] [int] NULL,
[timestamp] [timestamp] NULL,
[def_equip_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[def_cmd_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[def_required] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[def_expire_date] [datetime] NULL,
[def_cmp_billto] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[loadreqdefault_ident] [int] NOT NULL IDENTITY(1, 1),
[lrd_id] [int] NULL,
[def_field] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[def_units] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ltl_applicable] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[lrdident_id]
   ON  [dbo].[loadreqdefault]
   AFTER  INSERT
AS 
BEGIN
	
	declare @id int

	Select @id  = loadreqdefault_ident
From inserted


update loadreqdefault set lrd_id = @id
where loadreqdefault_ident = @id

	SET NOCOUNT ON;

    -- Insert statements for trigger here

END
GO
ALTER TABLE [dbo].[loadreqdefault] ADD CONSTRAINT [PK_loadreqdefault] PRIMARY KEY NONCLUSTERED ([loadreqdefault_ident]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [indx1_defprimary] ON [dbo].[loadreqdefault] ([def_id], [def_id_type], [def_type], [def_not], [def_manditory], [def_equip_type], [def_cmd_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[loadreqdefault] TO [public]
GO
GRANT INSERT ON  [dbo].[loadreqdefault] TO [public]
GO
GRANT REFERENCES ON  [dbo].[loadreqdefault] TO [public]
GO
GRANT SELECT ON  [dbo].[loadreqdefault] TO [public]
GO
GRANT UPDATE ON  [dbo].[loadreqdefault] TO [public]
GO
