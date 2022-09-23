CREATE TABLE [dbo].[driverdocument]
(
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[drd_doctype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[drd_docnumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[drd_stateofissue] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drd_countryofissue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drd_default] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drd_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[driverdocument] ADD CONSTRAINT [pk_driverdocument] PRIMARY KEY CLUSTERED ([mpp_id], [drd_doctype], [drd_docnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[driverdocument] TO [public]
GO
GRANT INSERT ON  [dbo].[driverdocument] TO [public]
GO
GRANT REFERENCES ON  [dbo].[driverdocument] TO [public]
GO
GRANT SELECT ON  [dbo].[driverdocument] TO [public]
GO
GRANT UPDATE ON  [dbo].[driverdocument] TO [public]
GO
