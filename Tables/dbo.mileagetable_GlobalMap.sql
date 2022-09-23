CREATE TABLE [dbo].[mileagetable_GlobalMap]
(
[mt_type] [int] NOT NULL,
[mt_origintype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mt_destinationtype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
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
[mt_lastused] [datetime] NULL,
[mt_ejes] [int] NULL,
[mt_cmporigen] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mt_cmpdestino] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
