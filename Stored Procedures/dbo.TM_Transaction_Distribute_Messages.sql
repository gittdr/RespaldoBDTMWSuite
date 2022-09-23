SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[TM_Transaction_Distribute_Messages]    
AS    
    
/**    
 *     
 * NAME:    
 * dbo.TM_Transaction_Distribute_Messages    
 *    
 * TYPE:    
 * Stored Procedure    
 *    
 * DESCRIPTION:    
 * Used for Message Balancing. Main Procedure for TotalMail side (Inbound).    
 *   Handles top level processing of TotalMail side (tblServer) Transaction Server entries.     
 *   Including list cleanup and if Messages need redistribution.    
 *    
 * RETURNS:    
 * NONE    
 *     
 * PARAMETERS:    
 * NONE    
 *     
 * Change Log:     
 * DWG 05/01/2013 PTS 61250 - Created    
 *    
 **/    
     
/*    
 Flags:    
   1 = Active    
   2 = Polling    
   4 = Reset    
   8 = Start up    
   16 = Shutdown Request    
   32 = Shutdown Successful    
       
   Data  = List of Truck/Driver SNs processed by Transaction Server    
   Data2 = List of Truck/Driver SNs that are exclusive to the Transaction Server. Data should only have entrire that match Data2    
*/    
    
SET NOCOUNT ON    
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED -- DIRTY READS FOR ALL TABLES IN THIS TRANSACTION Or REM this line and use (NOLOCK)    
    
DECLARE @iTranSN int,    
  @iTranInboxSN int,    
  @iTranInboxMsgCount int,    
  @iRedistributeMsgCount int,    
  @iTransWithPlusInboxMsgCount int,    
  @iTransWithUnderInboxMsgCount int,    
  @iActiveTransCount int,      
  @iInactiveTransCount int,    
  @iRedistributeMsgPct int,    
  @iForceRedistributionOfMessages int    
    
DECLARE @ExclusiveTruckList varchar(max),    
  @ProcessedTruckList varchar(max) ,    
  @Split char(1),    
  @ExclusiveTrucks xml,    
  @ProcessedTrucks xml,    
  @TruckIDSN int,    
  @sMessageBalancingIsOn varchar(10)    
    
DECLARE @ExclusiveTrucksTable TABLE (TruckID varchar(50))    
DECLARE @ProcessedTrucksTable TABLE (TruckID varchar(50))    
    
SELECT @sMessageBalancingIsOn = ISNULL(Text, 0) FROM tblRS WHERE keyCode = 'InbMsgBal'    
if @sMessageBalancingIsOn = 'True'     
BEGIN    
    
SELECT @iRedistributeMsgCount = CONVERT(int, ISNULL(Text, 0)) FROM tblRS WHERE keyCode = 'TrnRdstCt'    
if @iRedistributeMsgCount = 0 SET @iRedistributeMsgCount = 50    
    
SELECT @iRedistributeMsgPct = CONVERT(int, ISNULL(Text, 0)) FROM tblRS WHERE keyCode = 'TrnRdstPct'    
if @iRedistributeMsgPct = 0 SET @iRedistributeMsgPct = 60    
    
--Get count of Transaction agents that are turned on for balancing and not being reset.    
SELECT @iActiveTransCount = COUNT(*)     
 FROM tblServer     
 WHERE LEFT(ServerCode, 1) = 'T'     
   AND (Flags & 1 > 0)     
   AND (Flags & 4 = 0) --Do not include Transaction Servers that are in reset mode    
   AND (Flags & 8 = 0) --Do not include Transaction Servers that are starting up    
   AND ISNULL([Data2], '') = '' --Do not include Exclusive Transaction Servers    
    
if @iActiveTransCount = 0 SET @iActiveTransCount = 1    
    
--Get count of Transaction agents that are turned disabled for balancing. (Flag AND 1)    
SELECT @iInactiveTransCount = COUNT(*) FROM tblServer WHERE LEFT(ServerCode, 1) = 'T' AND Flags & 1 = 0    
    
SET @iForceRedistributionOfMessages = 0    
    
--Was there a Successful Shutdown for any Transaction Agent? Flag AND 32    
IF EXISTS (SELECT NULL FROM tblServer WHERE Flags & 32 > 0)    
 BEGIN    
  --Set the tblServer Flag = NULL and set the Reset and ResetRequest columns to NULL    
  UPDATE tblServer     
   SET ResetRequest = NULL,     
    [Reset] = NULL,     
    Flags = NULL     
   WHERE Flags & 32 > 0    
       
  --Redistribute the Messages    
  EXEC TM_Transaction_ReDistribute_Messages @iActiveTransCount, 1    
 END    
    
ELSE IF EXISTS (SELECT NULL FROM tblServer WHERE (Flags & 8 > 0) AND (Flags & 4 = 0))    
 --New Transaction Agent started up. Redistribute the messages    
 BEGIN    
  --Redistribute the Messages    
  EXEC TM_Transaction_ReDistribute_Messages @iActiveTransCount, 1    
 END    
    
ELSE --No Transaction agents to Shutdown    
    
 BEGIN    
  --Do any transaction (1-x) inboxes have messages -->NO    
     
  IF NOT EXISTS (  
  SELECT top 1  m.folder FROM tblMessages m inner join tblServer s   
  on m.Folder = s.Inbox where LEFT(s.ServerCode, 1) = 'T'           AND s.Flags & 1 > 0           AND ISNULL(s.[Data2], '') = '')  
   
  --IF (SELECT COUNT(*)     
  -- FROM tblMessages     
  -- WHERE Folder IN (SELECT Inbox     
  --      FROM tblServer     
  --      WHERE LEFT(ServerCode, 1) = 'T'    
  --       AND Flags & 1 > 0    
  --       AND ISNULL([Data2], '') = '' --Do not include Exclusive Transaction Servers    
  --     )) = 0    
             
   BEGIN     
    --Clear All Truck lists. (Clear Column in tblServer) - (Clear inactive also)    
    UPDATE tblServer     
     SET [Data] = NULL     
     WHERE LEFT(ServerCode, 1) = 'T'     
      AND ISNULL([Data2], '') = '' --Do not include Exclusive Transaction Servers    
    
    EXEC TM_Transaction_Move_Messages @iActiveTransCount    
   END    
    
  ELSE IF @iActiveTransCount > 1  --if we have more than 1 active transaction, do any transaction (1-x) inboxes have messages --> YES    
    
   BEGIN    
    SET @iTransWithPlusInboxMsgCount = 0    
    SET @iTransWithUnderInboxMsgCount = 0    
    --Walk Through Each Active non-exclusive Transaction Server Inbox (Flag 1 = Active)    
    SELECT @iTranSN = MIN(SN)     
     FROM tblServer     
     WHERE LEFT(ServerCode, 1) = 'T'     
      AND (Flags & 1 > 0)    
      AND ISNULL([Data2], '') = '' --Do not include Exclusive Transaction Servers    
        
    WHILE ISNULL(@iTranSN, 0) > 0    
    BEGIN    
         
     --Get the Inbox Folder SN for the Transaction Agent    
     SELECT @iTranInboxSN = Inbox     
      FROM tblServer     
      WHERE SN = @iTranSN     
         
     --check if we have more Message than the Redistribute Message Count    
     SELECT @iTranInboxMsgCount = COUNT(*)     
      FROM tblMessages     
      WHERE Folder = @iTranInboxSN     
    
     IF @iTranInboxMsgCount >= @iRedistributeMsgCount    
      SET @iTransWithPlusInboxMsgCount = @iTransWithPlusInboxMsgCount + 1    
     ELSE       
      SET @iTransWithUnderInboxMsgCount = @iTransWithUnderInboxMsgCount + 1    
         
     --Any Messages in Inbox? if not then clear the truck list    
     IF @iTranInboxMsgCount = 0    
      --Clear Truck List for Transaction Agent    
      UPDATE tblServer     
       SET [Data] = NULL     
       WHERE SN = @iTranSN     
         
     ---Get Next Transaction Agent to check                    
     SELECT @iTranSN = MIN(SN)     
      FROM tblServer      
      WHERE LEFT(ServerCode, 1) = 'T'     
       AND Flags & 1 > 0     
       AND ISNULL([Data2], '') = '' --Do not include Exclusive Transaction Servers    
       AND SN > @iTranSN    
         
    END --Walk Through Each Transaction Agent    
    
    --Walk Through Each Active Exclusive Transaction Server Inbox (Flag 1 = Active)    
    SELECT @iTranSN = MIN(SN)     
     FROM tblServer     
     WHERE LEFT(ServerCode, 1) = 'T'     
      AND Flags & 1 > 0    
      AND ISNULL([Data2], '') <> '' --Only include Exclusive Transaction Servers    
        
    WHILE ISNULL(@iTranSN, 0) > 0    
    BEGIN    
         
     --Get the Inbox Folder SN for the Transaction Agent    
     SELECT @iTranInboxSN = Inbox,     
       @ProcessedTruckList = [Data],     
       @ExclusiveTruckList = [Data2],      
       @Split = ','    
      FROM tblServer     
      WHERE SN = @iTranSN     
    
     --Split the Exclusive Truck list [Data2]    
     --  Begin fancy way of splitting a comman delimited list    
     SELECT @ExclusiveTrucks = CONVERT(xml,'<root><s>' + REPLACE(@ExclusiveTruckList, @Split,'</s><s>') + '</s></root>')    
    
     DELETE @ExclusiveTrucksTable    
     INSERT INTO @ExclusiveTrucksTable (TruckID )    
      SELECT T.c.value('.','varchar(20)')    
      FROM @ExclusiveTrucks.nodes('/root/s') T(c)    
     --  End fancy way of splitting a comman delimited list    
    
     --Split the Processed Truck list [Data]    
     --  Begin fancy way of splitting a comman delimited list    
     SELECT @ProcessedTrucks = CONVERT(xml,'<root><s>' + REPLACE(@ProcessedTruckList, @Split,'</s><s>') + '</s></root>')    
    
     DELETE @ProcessedTrucksTable    
     INSERT INTO @ProcessedTrucksTable (TruckID )    
      SELECT T.c.value('.','varchar(20)')    
      FROM @ProcessedTrucks.nodes('/root/s') T(c)    
     --  End fancy way of splitting a comman delimited list    
         
     --Check to make sure the Truck being processed are in the Exclusive list    
     IF (SELECT COUNT(*)    
      FROM @ProcessedTrucksTable    
      WHERE TruckID NOT IN (SELECT TruckID FROM @ExclusiveTrucksTable)) > 0     
      BEGIN    
       --We have Trucks in this Transaction Agent that are not in the exclusive list    
       -- redistribue and get rid of them.    
           
       --Just redistribute this Transaction Server messages    
       SET @iForceRedistributionOfMessages = 1    
      END    
        
     ---Get Next Transaction Agent to check                    
     SELECT @iTranSN = MIN(SN)     
      FROM tblServer      
      WHERE LEFT(ServerCode, 1) = 'T'     
       AND Flags & 1 > 0     
       AND ISNULL([Data2], '') = '' --Do not include Exclusive Transaction Servers    
       AND SN > @iTranSN    
         
    END --Walk Through Each Transaction Agent    
    
   IF @iForceRedistributionOfMessages = 1    
    EXEC TM_Transaction_ReDistribute_Messages @iActiveTransCount, 1    
   ELSE    
    BEGIN    
     if @iRedistributeMsgPct > 0    
      BEGIN    
      --if Redistribute Percentage or less of all the transacts have +Redistribute Percentage messages    
      If (@iTransWithPlusInboxMsgCount / @iActiveTransCount) < (@iRedistributeMsgPct /100)    
       --If the percentage of message in the other inboxes is remainder of Redistribute Percentage or less, redistribute the messages    
       If @iTransWithUnderInboxMsgCount / @iTransWithPlusInboxMsgCount < ((100 - @iRedistributeMsgPct) / 100)    
        --Redistribute the Messages    
        EXEC TM_Transaction_ReDistribute_Messages @iActiveTransCount, 0    
       ELSE    
        EXEC TM_Transaction_Move_Messages @iActiveTransCount    
      ELSE    
       EXEC TM_Transaction_Move_Messages @iActiveTransCount    
      END --@iRedistributeMsgPct > 0    
     ELSE -- @iRedistributeMsgPct = 0    
      EXEC TM_Transaction_Move_Messages @iActiveTransCount    
            
    END --@iForceRedistributionOfMessages > 1    
   END --@iActiveTransCount > 1     
         
  ELSE --Do any transaction (1-x) inboxes have messages - only 1 or no transaction agents     
   EXEC TM_Transaction_Move_Messages @iActiveTransCount    
      
 END --No Transaction agents to Shutdown    
END --Message balancing turned on     

GO
GRANT EXECUTE ON  [dbo].[TM_Transaction_Distribute_Messages] TO [public]
GO
