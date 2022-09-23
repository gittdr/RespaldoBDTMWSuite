CREATE TABLE [dbo].[generalinfo]
(
[gi_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[gi_datein] [datetime] NOT NULL,
[gi_string1] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gi_string2] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gi_string3] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gi_string4] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gi_integer1] [int] NULL,
[gi_integer2] [int] NULL,
[gi_integer3] [int] NULL,
[gi_integer4] [int] NULL,
[gi_date1] [datetime] NULL,
[gi_date2] [datetime] NULL,
[gi_appid] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gi_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE trigger [dbo].[ut_generalinfo] on [dbo].[generalinfo] for update,delete as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
if (select count(*) from deleted) > 0 
	insert into generalinfoaudit
		(gi_name,
		gi_datein,                                                                                
		gi_string1,                                                                                                                       
		gi_string2 ,                                                                                                                      
		gi_string3  ,                                                                                                                     
		gi_string4   ,                                                                                                                    
		gi_integer1   ,                                                                                                                   
		gi_integer2    ,                                                                                                                  
		gi_integer3     ,                                                                                                                 
		gi_integer4      ,                                                                                                                
		gi_date1          ,                                                                                                               
		gi_date2           ,                                                                                                              
		gi_appid            ,                                                                                                             
		gi_description )
	select gi_name,
		gi_datein,                                                                                
		gi_string1,                                                                                                                       
		gi_string2 ,                                                                                                                      
		gi_string3  ,                                                                                                                     
		gi_string4   ,                                                                                                                    
		gi_integer1   ,                                                                                                                   
		gi_integer2    ,                                                                                                                  
		gi_integer3     ,                                                                                                                 
		gi_integer4      ,                                                                                                                
		gi_date1          ,                                                                                                               
		gi_date2           ,                                                                                                              
		gi_appid            ,                                                                                                             
		gi_description                                                                                                                   
	from deleted
GO
ALTER TABLE [dbo].[generalinfo] ADD CONSTRAINT [pk_generalinfo] PRIMARY KEY CLUSTERED ([gi_name], [gi_datein]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_gi_string1] ON [dbo].[generalinfo] ([gi_string1]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[generalinfo] TO [public]
GO
GRANT INSERT ON  [dbo].[generalinfo] TO [public]
GO
GRANT REFERENCES ON  [dbo].[generalinfo] TO [public]
GO
GRANT SELECT ON  [dbo].[generalinfo] TO [public]
GO
GRANT UPDATE ON  [dbo].[generalinfo] TO [public]
GO
