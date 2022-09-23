SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[terminal_users]
AS
  SELECT DISTINCT 'USR' user_type, ttsusers.usr_userid user_id, ttsusers.usr_fname firstname, ttsusers.usr_lname lastname, ttsusers.usr_booking_terminal terminal FROM ttsusers
  UNION
  SELECT DISTINCT 'DRV' user_type, mpp_id user_id, mpp_firstname firstname, mpp_lastname lastname, mpp_terminal terminal from manpowerprofile
  UNION
  SELECT DISTINCT 'EMP' user_type, EMPLOYEEPROFILE.ee_ID user_id, EMPLOYEEPROFILE.ee_firstname firstname, EMPLOYEEPROFILE.ee_lastname lastname, EMPLOYEEPROFILE.ee_Terminal terminal from EMPLOYEEPROFILE
GO
GRANT DELETE ON  [dbo].[terminal_users] TO [public]
GO
GRANT INSERT ON  [dbo].[terminal_users] TO [public]
GO
GRANT REFERENCES ON  [dbo].[terminal_users] TO [public]
GO
GRANT SELECT ON  [dbo].[terminal_users] TO [public]
GO
GRANT UPDATE ON  [dbo].[terminal_users] TO [public]
GO
