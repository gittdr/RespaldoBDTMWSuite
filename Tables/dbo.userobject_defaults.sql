CREATE TABLE [dbo].[userobject_defaults]
(
[uod_id] [int] NOT NULL,
[object] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[id] [int] NOT NULL,
[default_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[default_user_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[itut_userobject_defaults] ON [dbo].[userobject_defaults] FOR INSERT , UPDATE
AS
/**
 * 
 * NAME:
 * dbo.itut_userobjectdefaults
 *
 * TYPE:
 * [Trigger] 
 *
 * DESCRIPTION:
 * This trigger deletes the inserted record if the userobject object contains '::' indicating trigger it_userobject
 *         tagged it to make it invalid, bacause created by non admin person. It resets the original value if 
 *         being changed to a bad bject
 *
 * RETURNS:
 * nothing
 *
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * NONE
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * 
 * REVISION HISTORY:
 * 04/18/2006.01 ? PTS32630 - DPETE ? Created. Pauls Hauling wants to disallow non admins from saving trip grids
 *  04/14/09 DPETE should be checking GI setting to see if userobjects management is restricted to admins
 **/

 /* if userobject record was deleted by its trigger, do not allow userobject_defaults change to occur */
if exists (select 1 from generalinfo where gi_name = 'ScreenDesignForAdminUsersOnly'
and left(gi_string1,1)  = 'Y' ) 
  If not exists (select userobject.object from userobject,inserted where userobject.id = inserted.id)
    rollback transaction
       



return
GO
ALTER TABLE [dbo].[userobject_defaults] ADD CONSTRAINT [PK_userobject_defaults] PRIMARY KEY CLUSTERED ([uod_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[userobject_defaults] TO [public]
GO
GRANT INSERT ON  [dbo].[userobject_defaults] TO [public]
GO
GRANT REFERENCES ON  [dbo].[userobject_defaults] TO [public]
GO
GRANT SELECT ON  [dbo].[userobject_defaults] TO [public]
GO
GRANT UPDATE ON  [dbo].[userobject_defaults] TO [public]
GO
