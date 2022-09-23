CREATE TABLE [dbo].[acct_glnum]
(
[tts_co] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[acct_type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sequence_id] [int] NOT NULL,
[gl_key1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_key2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_key3] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_key4] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_key5] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_key6] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_key7] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_key8] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_key9] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_key10] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seg1] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seg2] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seg3] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seg4] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updateddate] [datetime] NULL,
[createdate] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[acct_glnum] TO [public]
GO
GRANT INSERT ON  [dbo].[acct_glnum] TO [public]
GO
GRANT REFERENCES ON  [dbo].[acct_glnum] TO [public]
GO
GRANT SELECT ON  [dbo].[acct_glnum] TO [public]
GO
GRANT UPDATE ON  [dbo].[acct_glnum] TO [public]
GO
