CREATE TABLE [dbo].[employerprofile]
(
[emp_id] [int] NOT NULL IDENTITY(1, 1),
[emp_name] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[emp_addr1] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[emp_addr2] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[emp_city] [int] NULL,
[emp_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[emp_phone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[emp_faxphone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[emp_email] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[emp_contact] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[emp_web] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[employerprofile] ADD CONSTRAINT [PK__employerprofile__3284FAF3] PRIMARY KEY CLUSTERED ([emp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[employerprofile] TO [public]
GO
GRANT INSERT ON  [dbo].[employerprofile] TO [public]
GO
GRANT REFERENCES ON  [dbo].[employerprofile] TO [public]
GO
GRANT SELECT ON  [dbo].[employerprofile] TO [public]
GO
GRANT UPDATE ON  [dbo].[employerprofile] TO [public]
GO
