CREATE TABLE [dbo].[ResNow_TrailerCache_Extract]
(
[trailer_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trailer_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trailer_type1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trailer_type2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trailer_type3] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trailer_type4] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trailer_company] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trailer_division] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trailer_terminal] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trailer_fleet] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trailer_branch] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trailer_owner] [varchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trailer_make] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trailer_model] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trailer_year] [int] NOT NULL,
[trailer_grossweight] [int] NULL,
[trailer_tareweight] [float] NULL,
[trailer_axles] [smallint] NOT NULL,
[trailer_height] [float] NOT NULL,
[trailer_length] [float] NOT NULL,
[trailer_width] [float] NOT NULL,
[trailer_licensestate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trailer_licensenumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trailer_startdate] [datetime] NULL,
[trailer_dateacquired] [datetime] NULL,
[trailer_retiredate] [datetime] NULL,
[trailer_DateStart] [datetime] NULL,
[trailer_DateEnd] [datetime] NULL,
[ResNow_TrailerCache_Extract_ident] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ResNow_TrailerCache_Extract] ADD CONSTRAINT [prkey_ResNow_TrailerCache_Extract] PRIMARY KEY CLUSTERED ([ResNow_TrailerCache_Extract_ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ResNow_TrailerCache_Extract] TO [public]
GO
GRANT INSERT ON  [dbo].[ResNow_TrailerCache_Extract] TO [public]
GO
GRANT SELECT ON  [dbo].[ResNow_TrailerCache_Extract] TO [public]
GO
GRANT UPDATE ON  [dbo].[ResNow_TrailerCache_Extract] TO [public]
GO
