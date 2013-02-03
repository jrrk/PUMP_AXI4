-----------------------------------------------------------------------------------
--!     @file    pump_axi4_to_axi4_core.vhd
--!     @brief   Pump Core Module (AXI4 to AXI4)
--!     @version 0.0.12
--!     @date    2013/2/3
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012,2013 Ichiro Kawazome
--      All rights reserved.
--
--      Redistribution and use in source and binary forms, with or without
--      modification, are permitted provided that the following conditions
--      are met:
--
--        1. Redistributions of source code must retain the above copyright
--           notice, this list of conditions and the following disclaimer.
--
--        2. Redistributions in binary form must reproduce the above copyright
--           notice, this list of conditions and the following disclaimer in
--           the documentation and/or other materials provided with the
--           distribution.
--
--      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
--      "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
--      LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
--      A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
--      OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
--      SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
--      LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
--      DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
--      THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
--      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
--      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PipeWork;
use     PipeWork.AXI4_TYPES.all;
-----------------------------------------------------------------------------------
--! @brief 
-----------------------------------------------------------------------------------
entity  PUMP_AXI4_TO_AXI4_CORE is
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    generic (
        I_ADDR_WIDTH    : integer range 1 to AXI4_ADDR_MAX_WIDTH := 32;
        I_DATA_WIDTH    : integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
        I_ID_WIDTH      : integer range 1 to AXI4_ID_MAX_WIDTH   := AXI4_ID_MAX_WIDTH;
        I_AUSER_WIDTH   : integer range 1 to 32                  :=  4;
        I_RUSER_WIDTH   : integer range 1 to 32                  :=  4;
        I_AXI_ID        : integer                                :=  1;
        I_REG_ADDR_BITS : integer                                := 32;
        I_REG_SIZE_BITS : integer                                := 32;
        I_REG_MODE_BITS : integer                                := 32;
        I_REG_STAT_BITS : integer                                := 32;
        I_MAX_XFER_SIZE : integer                                :=  8;
        I_RES_QUEUE     : integer                                :=  1;
        O_ADDR_WIDTH    : integer range 1 to AXI4_ADDR_MAX_WIDTH := 32;
        O_DATA_WIDTH    : integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
        O_ID_WIDTH      : integer range 1 to AXI4_ID_MAX_WIDTH   := AXI4_ID_MAX_WIDTH;
        O_AUSER_WIDTH   : integer range 1 to 32                  :=  4;
        O_WUSER_WIDTH   : integer range 1 to 32                  :=  4;
        O_BUSER_WIDTH   : integer range 1 to 32                  :=  4;
        O_AXI_ID        : integer                                :=  2;
        O_REG_ADDR_BITS : integer                                := 32;
        O_REG_SIZE_BITS : integer                                := 32;
        O_REG_MODE_BITS : integer                                := 32;
        O_REG_STAT_BITS : integer                                := 32;
        O_MAX_XFER_SIZE : integer                                :=  8;
        O_RES_QUEUE     : integer                                :=  2;
        BUF_DEPTH       : integer                                := 12
    );
    -------------------------------------------------------------------------------
    -- 入出力ポートの定義.
    -------------------------------------------------------------------------------
    port(
        ---------------------------------------------------------------------------
        -- Clock & Reset Signals.
        ---------------------------------------------------------------------------
        CLK             : in  std_logic; 
        RST             : in  std_logic;
        CLR             : in  std_logic;
        ---------------------------------------------------------------------------
        -- Intake Control Register Interface.
        ---------------------------------------------------------------------------
        I_ADDR_L        : in  std_logic_vector(I_REG_ADDR_BITS-1 downto 0);
        I_ADDR_D        : in  std_logic_vector(I_REG_ADDR_BITS-1 downto 0);
        I_ADDR_Q        : out std_logic_vector(I_REG_ADDR_BITS-1 downto 0);
        I_SIZE_L        : in  std_logic_vector(I_REG_SIZE_BITS-1 downto 0);
        I_SIZE_D        : in  std_logic_vector(I_REG_SIZE_BITS-1 downto 0);
        I_SIZE_Q        : out std_logic_vector(I_REG_SIZE_BITS-1 downto 0);
        I_MODE_L        : in  std_logic_vector(I_REG_MODE_BITS-1 downto 0);
        I_MODE_D        : in  std_logic_vector(I_REG_MODE_BITS-1 downto 0);
        I_MODE_Q        : out std_logic_vector(I_REG_MODE_BITS-1 downto 0);
        I_STAT_L        : in  std_logic_vector(I_REG_STAT_BITS-1 downto 0);
        I_STAT_D        : in  std_logic_vector(I_REG_STAT_BITS-1 downto 0);
        I_STAT_Q        : out std_logic_vector(I_REG_STAT_BITS-1 downto 0);
        I_STAT_I        : in  std_logic_vector(I_REG_STAT_BITS-1 downto 0);
        I_RESET_L       : in  std_logic;
        I_RESET_D       : in  std_logic;
        I_RESET_Q       : out std_logic;
        I_START_L       : in  std_logic;
        I_START_D       : in  std_logic;
        I_START_Q       : out std_logic;
        I_STOP_L        : in  std_logic;
        I_STOP_D        : in  std_logic;
        I_STOP_Q        : out std_logic;
        I_PAUSE_L       : in  std_logic;
        I_PAUSE_D       : in  std_logic;
        I_PAUSE_Q       : out std_logic;
        I_FIRST_L       : in  std_logic;
        I_FIRST_D       : in  std_logic;
        I_FIRST_Q       : out std_logic;
        I_LAST_L        : in  std_logic;
        I_LAST_D        : in  std_logic;
        I_LAST_Q        : out std_logic;
        I_DONE_EN_L     : in  std_logic;
        I_DONE_EN_D     : in  std_logic;
        I_DONE_EN_Q     : out std_logic;
        I_DONE_ST_L     : in  std_logic;
        I_DONE_ST_D     : in  std_logic;
        I_DONE_ST_Q     : out std_logic;
        I_ERR_ST_L      : in  std_logic;
        I_ERR_ST_D      : in  std_logic;
        I_ERR_ST_Q      : out std_logic;
        I_ADDR_FIX      : in  std_logic;
        I_SPECULATIVE   : in  std_logic;
        I_SAFETY        : in  std_logic;
        I_CACHE         : in  AXI4_ACACHE_TYPE;
        I_LOCK          : in  AXI4_ALOCK_TYPE  ;
        I_PROT          : in  AXI4_APROT_TYPE  ;
        I_QOS           : in  AXI4_AQOS_TYPE   ;
        I_REGION        : in  AXI4_AREGION_TYPE;
        ---------------------------------------------------------------------------
        -- Outlet Control Register Interface.
        ---------------------------------------------------------------------------
        O_ADDR_L        : in  std_logic_vector(O_REG_ADDR_BITS-1 downto 0);
        O_ADDR_D        : in  std_logic_vector(O_REG_ADDR_BITS-1 downto 0);
        O_ADDR_Q        : out std_logic_vector(O_REG_ADDR_BITS-1 downto 0);
        O_SIZE_L        : in  std_logic_vector(O_REG_SIZE_BITS-1 downto 0);
        O_SIZE_D        : in  std_logic_vector(O_REG_SIZE_BITS-1 downto 0);
        O_SIZE_Q        : out std_logic_vector(O_REG_SIZE_BITS-1 downto 0);
        O_MODE_L        : in  std_logic_vector(O_REG_MODE_BITS-1 downto 0);
        O_MODE_D        : in  std_logic_vector(O_REG_MODE_BITS-1 downto 0);
        O_MODE_Q        : out std_logic_vector(O_REG_MODE_BITS-1 downto 0);
        O_STAT_L        : in  std_logic_vector(O_REG_STAT_BITS-1 downto 0);
        O_STAT_D        : in  std_logic_vector(O_REG_STAT_BITS-1 downto 0);
        O_STAT_Q        : out std_logic_vector(O_REG_STAT_BITS-1 downto 0);
        O_STAT_I        : in  std_logic_vector(O_REG_STAT_BITS-1 downto 0);
        O_RESET_L       : in  std_logic;
        O_RESET_D       : in  std_logic;
        O_RESET_Q       : out std_logic;
        O_START_L       : in  std_logic;
        O_START_D       : in  std_logic;
        O_START_Q       : out std_logic;
        O_STOP_L        : in  std_logic;
        O_STOP_D        : in  std_logic;
        O_STOP_Q        : out std_logic;
        O_PAUSE_L       : in  std_logic;
        O_PAUSE_D       : in  std_logic;
        O_PAUSE_Q       : out std_logic;
        O_FIRST_L       : in  std_logic;
        O_FIRST_D       : in  std_logic;
        O_FIRST_Q       : out std_logic;
        O_LAST_L        : in  std_logic;
        O_LAST_D        : in  std_logic;
        O_LAST_Q        : out std_logic;
        O_DONE_EN_L     : in  std_logic;
        O_DONE_EN_D     : in  std_logic;
        O_DONE_EN_Q     : out std_logic;
        O_DONE_ST_L     : in  std_logic;
        O_DONE_ST_D     : in  std_logic;
        O_DONE_ST_Q     : out std_logic;
        O_ERR_ST_L      : in  std_logic;
        O_ERR_ST_D      : in  std_logic;
        O_ERR_ST_Q      : out std_logic;
        O_ADDR_FIX      : in  std_logic;
        O_SPECULATIVE   : in  std_logic;
        O_SAFETY        : in  std_logic;
        O_CACHE         : in  AXI4_ACACHE_TYPE ;
        O_LOCK          : in  AXI4_ALOCK_TYPE  ;
        O_PROT          : in  AXI4_APROT_TYPE  ;
        O_QOS           : in  AXI4_AQOS_TYPE   ;
        O_REGION        : in  AXI4_AREGION_TYPE;
        --------------------------------------------------------------------------
        -- Input AXI4 Read Address Channel Signals.
        --------------------------------------------------------------------------
        I_ARID          : out std_logic_vector(I_ID_WIDTH    -1 downto 0);
        I_ARADDR        : out std_logic_vector(I_ADDR_WIDTH  -1 downto 0);
        I_ARLEN         : out AXI4_ALEN_TYPE;
        I_ARSIZE        : out AXI4_ASIZE_TYPE;
        I_ARBURST       : out AXI4_ABURST_TYPE;
        I_ARLOCK        : out AXI4_ALOCK_TYPE;
        I_ARCACHE       : out AXI4_ACACHE_TYPE;
        I_ARPROT        : out AXI4_APROT_TYPE;
        I_ARQOS         : out AXI4_AQOS_TYPE;
        I_ARREGION      : out AXI4_AREGION_TYPE;
        I_ARUSER        : out std_logic_vector(I_AUSER_WIDTH -1 downto 0);
        I_ARVALID       : out std_logic;
        I_ARREADY       : in  std_logic;
        --------------------------------------------------------------------------
        -- Input AXI4 Read Data Channel Signals.
        --------------------------------------------------------------------------
        I_RID           : in  std_logic_vector(I_ID_WIDTH    -1 downto 0);
        I_RDATA         : in  std_logic_vector(I_DATA_WIDTH  -1 downto 0);
        I_RRESP         : in  AXI4_RESP_TYPE;
        I_RLAST         : in  std_logic;
        I_RUSER         : in  std_logic_vector(I_RUSER_WIDTH -1 downto 0);
        I_RVALID        : in  std_logic;
        I_RREADY        : out std_logic;
        --------------------------------------------------------------------------
        -- Output AXI4 Write Address Channel Signals.
        --------------------------------------------------------------------------
        O_AWID          : out std_logic_vector(O_ID_WIDTH    -1 downto 0);
        O_AWADDR        : out std_logic_vector(O_ADDR_WIDTH  -1 downto 0);
        O_AWLEN         : out AXI4_ALEN_TYPE;
        O_AWSIZE        : out AXI4_ASIZE_TYPE;
        O_AWBURST       : out AXI4_ABURST_TYPE;
        O_AWLOCK        : out AXI4_ALOCK_TYPE;
        O_AWCACHE       : out AXI4_ACACHE_TYPE;
        O_AWPROT        : out AXI4_APROT_TYPE;
        O_AWQOS         : out AXI4_AQOS_TYPE;
        O_AWREGION      : out AXI4_AREGION_TYPE;
        O_AWUSER        : out std_logic_vector(O_AUSER_WIDTH -1 downto 0);
        O_AWVALID       : out std_logic;
        O_AWREADY       : in  std_logic;
        --------------------------------------------------------------------------
        -- Output AXI4 Write Data Channel Signals.
        --------------------------------------------------------------------------
        O_WID           : out std_logic_vector(O_ID_WIDTH    -1 downto 0);
        O_WDATA         : out std_logic_vector(O_DATA_WIDTH  -1 downto 0);
        O_WSTRB         : out std_logic_vector(O_DATA_WIDTH/8-1 downto 0);
        O_WUSER         : out std_logic_vector(O_WUSER_WIDTH -1 downto 0);
        O_WLAST         : out std_logic;
        O_WVALID        : out std_logic;
        O_WREADY        : in  std_logic;
        --------------------------------------------------------------------------
        -- Output AXI4 Write Response Channel Signals.
        --------------------------------------------------------------------------
        O_BID           : in  std_logic_vector(O_ID_WIDTH    -1 downto 0);
        O_BRESP         : in  AXI4_RESP_TYPE;
        O_BUSER         : in  std_logic_vector(O_BUSER_WIDTH -1 downto 0);
        O_BVALID        : in  std_logic;
        O_BREADY        : out std_logic;
        ---------------------------------------------------------------------------
        -- Intake Status.
        ---------------------------------------------------------------------------
        I_OPEN          : out std_logic;
        I_RUNNING       : out std_logic;
        I_DONE          : out std_logic;
        I_ERROR         : out std_logic;
        ---------------------------------------------------------------------------
        -- Outlet Status.
        ---------------------------------------------------------------------------
        O_OPEN          : out std_logic;
        O_RUNNING       : out std_logic;
        O_DONE          : out std_logic;
        O_ERROR         : out std_logic
    );
end PUMP_AXI4_TO_AXI4_CORE;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.AXI4_TYPES.all;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_MASTER_READ_INTERFACE;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_MASTER_WRITE_INTERFACE;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_CONTROLLER;
use     PIPEWORK.COMPONENTS.SDPRAM;
architecture RTL of PUMP_AXI4_TO_AXI4_CORE is
    ------------------------------------------------------------------------------
    -- 各種サイズカウンタのビット数.
    ------------------------------------------------------------------------------
    constant SIZE_BITS          : integer := BUF_DEPTH+1;
    ------------------------------------------------------------------------------
    -- 最大転送バイト数.
    ------------------------------------------------------------------------------
    constant I_MAX_XFER_BYTES   : integer := 2**I_MAX_XFER_SIZE;
    constant O_MAX_XFER_BYTES   : integer := 2**O_MAX_XFER_SIZE;
    ------------------------------------------------------------------------------
    -- バッファデータのビット幅.
    ------------------------------------------------------------------------------
    function MAX(A,B:integer) return integer is begin
        if (A > B) then return A;
        else            return B;
        end if;
    end function;
    constant BUF_DATA_WIDTH     : integer := MAX(O_DATA_WIDTH,I_DATA_WIDTH);
    -------------------------------------------------------------------------------
    -- データバスのバイト数の２のべき乗値を計算する.
    -------------------------------------------------------------------------------
    function CALC_DATA_SIZE(WIDTH:integer) return integer is
        variable value : integer;
    begin
        value := 0;
        while (2**(value) < WIDTH) loop
            value := value + 1;
        end loop;
        return value;
    end function;
    ------------------------------------------------------------------------------
    -- バッファデータのビット幅をバイト数(２のべき乗値)で示す.
    ------------------------------------------------------------------------------
    constant BUF_DATA_SIZE      : integer := CALC_DATA_SIZE(BUF_DATA_WIDTH);
    ------------------------------------------------------------------------------
    -- 入力側の各種定数.
    ------------------------------------------------------------------------------
    constant I_CKE              : std_logic := '1';
    constant I_ID               : std_logic_vector(I_ID_WIDTH -1 downto 0) :=
                                  std_logic_vector(to_unsigned(I_AXI_ID, I_ID_WIDTH));
    constant I_XFER_SIZE_SEL    : std_logic_vector(I_MAX_XFER_SIZE downto I_MAX_XFER_SIZE) := "1";
    ------------------------------------------------------------------------------
    -- 入力側の各種信号群.
    ------------------------------------------------------------------------------
    signal   i_req_addr         : std_logic_vector(I_ADDR_WIDTH    -1 downto 0);
    signal   i_req_size         : std_logic_vector(I_REG_SIZE_BITS -1 downto 0);
    signal   i_req_buf_ptr      : std_logic_vector(BUF_DEPTH       -1 downto 0);
    signal   i_req_burst_type   : AXI4_ABURST_TYPE;
    signal   i_req_first        : std_logic;
    signal   i_req_last         : std_logic;
    signal   i_req_valid        : std_logic;
    signal   i_req_ready        : std_logic;
    signal   i_xfer_busy        : std_logic;
    signal   i_ack_valid        : std_logic;
    signal   i_ack_error        : std_logic;
    signal   i_ack_next         : std_logic;
    signal   i_ack_last         : std_logic;
    signal   i_ack_stop         : std_logic;
    signal   i_ack_none         : std_logic;
    signal   i_ack_size         : std_logic_vector(SIZE_BITS       -1 downto 0);
    signal   i_flow_pause       : std_logic;
    signal   i_flow_stop        : std_logic;
    signal   i_flow_last        : std_logic;
    signal   i_flow_size        : std_logic_vector(SIZE_BITS       -1 downto 0);
    signal   i_threshold_size   : std_logic_vector(SIZE_BITS       -1 downto 0);
    ------------------------------------------------------------------------------
    -- 出力側の各種定数.
    ------------------------------------------------------------------------------
    constant O_CKE              : std_logic := '1';
    constant O_ID               : std_logic_vector(O_ID_WIDTH -1 downto 0) := 
                                  std_logic_vector(to_unsigned(O_AXI_ID, O_ID_WIDTH));
    constant O_XFER_SIZE_SEL    : std_logic_vector(O_MAX_XFER_SIZE downto O_MAX_XFER_SIZE) := "1";
    ------------------------------------------------------------------------------
    -- 出力側の各種信号群.
    ------------------------------------------------------------------------------
    signal   o_req_addr         : std_logic_vector(O_ADDR_WIDTH    -1 downto 0);
    signal   o_req_size         : std_logic_vector(O_REG_SIZE_BITS -1 downto 0);
    signal   o_req_buf_ptr      : std_logic_vector(BUF_DEPTH       -1 downto 0);
    signal   o_req_burst_type   : AXI4_ABURST_TYPE;
    signal   o_req_first        : std_logic;
    signal   o_req_last         : std_logic;
    signal   o_req_valid        : std_logic;
    signal   o_req_ready        : std_logic;
    signal   o_xfer_busy        : std_logic;
    signal   o_ack_valid        : std_logic;
    signal   o_ack_error        : std_logic;
    signal   o_ack_next         : std_logic;
    signal   o_ack_last         : std_logic;
    signal   o_ack_stop         : std_logic;
    signal   o_ack_none         : std_logic;
    signal   o_ack_size         : std_logic_vector(SIZE_BITS       -1 downto 0);
    signal   o_flow_pause       : std_logic;
    signal   o_flow_stop        : std_logic;
    signal   o_flow_last        : std_logic;
    signal   o_flow_size        : std_logic_vector(SIZE_BITS       -1 downto 0);
    signal   o_threshold_size   : std_logic_vector(SIZE_BITS       -1 downto 0);
    ------------------------------------------------------------------------------
    -- フローカウンタ制御用信号群.
    ------------------------------------------------------------------------------
    signal   push_valid         : std_logic;
    signal   push_error         : std_logic;
    signal   push_last          : std_logic;
    signal   push_size          : std_logic_vector(SIZE_BITS       -1 downto 0);
    signal   pull_valid         : std_logic;
    signal   pull_error         : std_logic;
    signal   pull_last          : std_logic;
    signal   pull_size          : std_logic_vector(SIZE_BITS       -1 downto 0);
    ------------------------------------------------------------------------------
    -- バッファへのアクセス用信号群.
    ------------------------------------------------------------------------------
    signal   buf_wdata          : std_logic_vector(BUF_DATA_WIDTH  -1 downto 0);
    signal   buf_ben            : std_logic_vector(BUF_DATA_WIDTH/8-1 downto 0);
    signal   buf_we             : std_logic_vector(BUF_DATA_WIDTH/8-1 downto 0);
    signal   buf_wptr           : std_logic_vector(BUF_DEPTH       -1 downto 0);
    signal   buf_wen            : std_logic;
    constant buf_wready         : std_logic := '1';
    signal   buf_rdata          : std_logic_vector(BUF_DATA_WIDTH  -1 downto 0);
    signal   buf_rptr           : std_logic_vector(BUF_DEPTH       -1 downto 0);
    constant buf_rready         : std_logic := '1';
begin
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    I_IF: AXI4_MASTER_READ_INTERFACE
        generic map (
            AXI4_ADDR_WIDTH => I_ADDR_WIDTH    ,
            AXI4_DATA_WIDTH => I_DATA_WIDTH    ,
            AXI4_ID_WIDTH   => I_ID_WIDTH      ,
            VAL_BITS        => 1               ,
            SIZE_BITS       => SIZE_BITS       ,
            REQ_SIZE_BITS   => I_REG_SIZE_BITS,
            REQ_SIZE_VALID  => 1               ,
            FLOW_VALID      => 1               ,
            BUF_DATA_WIDTH  => BUF_DATA_WIDTH  ,
            BUF_PTR_BITS    => BUF_DEPTH       ,
            XFER_MIN_SIZE   => I_MAX_XFER_SIZE ,
            XFER_MAX_SIZE   => I_MAX_XFER_SIZE ,
            QUEUE_SIZE      => I_RES_QUEUE
        )
        port map (
        --------------------------------------------------------------------------
        -- Clock and Reset Signals.
        --------------------------------------------------------------------------
            CLK             => CLK             ,
            RST             => RST             ,
            CLR             => CLR             ,
        --------------------------------------------------------------------------
        -- AXI4 Read Address Channel Signals.
        --------------------------------------------------------------------------
            ARID            => I_ARID          , -- Out :
            ARADDR          => I_ARADDR        , -- Out :
            ARLEN           => I_ARLEN         , -- Out :
            ARSIZE          => I_ARSIZE        , -- Out :
            ARBURST         => I_ARBURST       , -- Out :
            ARLOCK          => I_ARLOCK        , -- Out :
            ARCACHE         => I_ARCACHE       , -- Out :
            ARPROT          => I_ARPROT        , -- Out :
            ARQOS           => I_ARQOS         , -- Out :
            ARREGION        => I_ARREGION      , -- Out :
            ARVALID         => I_ARVALID       , -- Out :
            ARREADY         => I_ARREADY       , -- In  :
        --------------------------------------------------------------------------
        -- AXI4 Read Data Channel Signals.
        --------------------------------------------------------------------------
            RID             => I_RID           , -- In  :
            RDATA           => I_RDATA         , -- In  :
            RRESP           => I_RRESP         , -- In  :
            RLAST           => I_RLAST         , -- In  :
            RVALID          => I_RVALID        , -- In  :
            RREADY          => I_RREADY        , -- Out :
        ---------------------------------------------------------------------------
        -- Command Request Signals.
        ---------------------------------------------------------------------------
            REQ_ADDR        => i_req_addr      , -- In  :
            REQ_SIZE        => i_req_size      , -- In  :
            REQ_ID          => I_ID            , -- In  :
            REQ_BURST       => i_req_burst_type, -- In  :
            REQ_LOCK        => I_LOCK          , -- In  :
            REQ_CACHE       => I_CACHE         , -- In  :
            REQ_PROT        => I_PROT          , -- In  :
            REQ_QOS         => I_QOS           , -- In  :
            REQ_REGION      => I_REGION        , -- In  :
            REQ_BUF_PTR     => i_req_buf_ptr   , -- In  :
            REQ_FIRST       => i_req_first     , -- In  :
            REQ_LAST        => i_req_last      , -- In  :
            REQ_SPECULATIVE => I_SPECULATIVE   , -- In  :
            REQ_SAFETY      => I_SAFETY        , -- In  :
            REQ_VAL(0)      => i_req_valid     , -- In  :
            REQ_RDY         => i_req_ready     , -- Out :
            XFER_SIZE_SEL   => I_XFER_SIZE_SEL , -- In  :
            XFER_BUSY       => i_xfer_busy     , -- Out :
        ---------------------------------------------------------------------------
        -- Response Signals.
        ---------------------------------------------------------------------------
            ACK_VAL(0)      => i_ack_valid     , -- Out :
            ACK_ERROR       => i_ack_error     , -- Out :
            ACK_NEXT        => i_ack_next      , -- Out :
            ACK_LAST        => i_ack_last      , -- Out :
            ACK_STOP        => i_ack_stop      , -- Out :
            ACK_NONE        => i_ack_none      , -- Out :
            ACK_SIZE        => i_ack_size      , -- Out :
        ---------------------------------------------------------------------------
        -- Flow Control Signals.
        ---------------------------------------------------------------------------
            FLOW_PAUSE      => i_flow_pause    , -- In  :
            FLOW_STOP       => i_flow_stop     , -- In  :
            FLOW_LAST       => i_flow_last     , -- In  :
            FLOW_SIZE       => i_flow_size     , -- In  :
        ---------------------------------------------------------------------------
        -- Reserve Size Signals.
        ---------------------------------------------------------------------------
            RESV_VAL        => open            , -- Out :
            RESV_SIZE       => open            , -- Out :
            RESV_LAST       => open            , -- Out :
            RESV_ERROR      => open            , -- Out :
        ---------------------------------------------------------------------------
        -- Push Size Signals.
        ---------------------------------------------------------------------------
            PUSH_VAL(0)     => push_valid      , -- Out :
            PUSH_SIZE       => push_size       , -- Out :
            PUSH_LAST       => push_last       , -- Out :
            PUSH_ERROR      => push_error      , -- Out :
        ---------------------------------------------------------------------------
        -- Read Buffer Interface Signals.
        ---------------------------------------------------------------------------
            BUF_WEN(0)      => buf_wen         , -- Out :
            BUF_BEN         => buf_ben         , -- Out :
            BUF_DATA        => buf_wdata       , -- Out :
            BUF_PTR         => buf_wptr        , -- Out :
            BUF_RDY         => buf_wready        -- In  :
        );
    I_ARUSER         <= (others => '0');
    i_req_burst_type <= AXI4_ABURST_FIXED when (I_ADDR_FIX = '1') else AXI4_ABURST_INCR;
    i_threshold_size <= std_logic_vector(to_unsigned(2**BUF_DEPTH-I_MAX_XFER_BYTES,SIZE_BITS));
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    O_IF: AXI4_MASTER_WRITE_INTERFACE
        generic map (
            AXI4_ADDR_WIDTH => O_ADDR_WIDTH    ,
            AXI4_DATA_WIDTH => O_DATA_WIDTH    ,
            AXI4_ID_WIDTH   => O_ID_WIDTH      ,
            VAL_BITS        => 1               ,
            SIZE_BITS       => SIZE_BITS       ,
            REQ_SIZE_BITS   => O_REG_SIZE_BITS ,
            REQ_SIZE_VALID  => 1               ,
            FLOW_VALID      => 1               ,
            BUF_DATA_WIDTH  => BUF_DATA_WIDTH  ,
            BUF_PTR_BITS    => BUF_DEPTH       ,
            XFER_MIN_SIZE   => O_MAX_XFER_SIZE ,
            XFER_MAX_SIZE   => O_MAX_XFER_SIZE ,
            QUEUE_SIZE      => O_RES_QUEUE
        )
        port map (
        --------------------------------------------------------------------------
        -- Clock and Reset Signals.
        --------------------------------------------------------------------------
            CLK             => CLK             ,
            RST             => RST             ,
            CLR             => CLR             ,
        --------------------------------------------------------------------------
        -- AXI4 Write Address Channel Signals.
        --------------------------------------------------------------------------
            AWID            => O_AWID          , -- Out :
            AWADDR          => O_AWADDR        , -- Out :
            AWLEN           => O_AWLEN         , -- Out :
            AWSIZE          => O_AWSIZE        , -- Out :
            AWBURST         => O_AWBURST       , -- Out :
            AWLOCK          => O_AWLOCK        , -- Out :
            AWCACHE         => O_AWCACHE       , -- Out :
            AWPROT          => O_AWPROT        , -- Out :
            AWQOS           => O_AWQOS         , -- Out :
            AWREGION        => O_AWREGION      , -- Out :
            AWVALID         => O_AWVALID       , -- Out :
            AWREADY         => O_AWREADY       , -- In  :
        --------------------------------------------------------------------------
        -- AXI4 Write Data Channel Signals.
        --------------------------------------------------------------------------
            WID             => O_WID           , -- Out :
            WDATA           => O_WDATA         , -- Out :
            WSTRB           => O_WSTRB         , -- Out :
            WLAST           => O_WLAST         , -- Out :
            WVALID          => O_WVALID        , -- Out :
            WREADY          => O_WREADY        , -- In  :
        --------------------------------------------------------------------------
        -- AXI4 Write Response Channel Signals.
        --------------------------------------------------------------------------
            BID             => O_BID           , -- In  :
            BRESP           => O_BRESP         , -- In  :
            BVALID          => O_BVALID        , -- In  :
            BREADY          => O_BREADY        , -- Out :
        ---------------------------------------------------------------------------
        -- Command Request Signals.
        ---------------------------------------------------------------------------
            REQ_ADDR        => o_req_addr      , -- In  :
            REQ_SIZE        => o_req_size      , -- In  :
            REQ_ID          => O_ID            , -- In  :
            REQ_BURST       => o_req_burst_type, -- In  :
            REQ_LOCK        => O_LOCK          , -- In  :
            REQ_CACHE       => O_CACHE         , -- In  :
            REQ_PROT        => O_PROT          , -- In  :
            REQ_QOS         => O_QOS           , -- In  :
            REQ_REGION      => O_REGION        , -- In  :
            REQ_BUF_PTR     => o_req_buf_ptr   , -- In  :
            REQ_FIRST       => o_req_first     , -- In  :
            REQ_LAST        => o_req_last      , -- In  :
            REQ_SPECULATIVE => O_SPECULATIVE   , -- In  :
            REQ_SAFETY      => O_SAFETY        , -- In  :
            REQ_VAL(0)      => o_req_valid     , -- In  :
            REQ_RDY         => o_req_ready     , -- Out :
            XFER_SIZE_SEL   => O_XFER_SIZE_SEL , -- In  :
            XFER_BUSY       => o_xfer_busy     , -- Out :
        ---------------------------------------------------------------------------
        -- Response Signals.
        ---------------------------------------------------------------------------
            ACK_VAL(0)      => o_ack_valid     , -- Out :
            ACK_ERROR       => o_ack_error     , -- Out :
            ACK_NEXT        => o_ack_next      , -- Out :
            ACK_LAST        => o_ack_last      , -- Out :
            ACK_STOP        => o_ack_stop      , -- Out :
            ACK_NONE        => o_ack_none      , -- Out :
            ACK_SIZE        => o_ack_size      , -- Out :
        ---------------------------------------------------------------------------
        -- Flow Control Signals.
        ---------------------------------------------------------------------------
            FLOW_PAUSE      => o_flow_pause    , -- In  :
            FLOW_STOP       => o_flow_stop     , -- In  :
            FLOW_LAST       => o_flow_last     , -- In  :
            FLOW_SIZE       => o_flow_size     , -- In  :
        ---------------------------------------------------------------------------
        -- Reserve Size Signals.
        ---------------------------------------------------------------------------
            RESV_VAL        => open            , -- Out :
            RESV_SIZE       => open            , -- Out :
            RESV_LAST       => open            , -- Out :
            RESV_ERROR      => open            , -- Out :
        ---------------------------------------------------------------------------
        -- Pull Size Signals.
        ---------------------------------------------------------------------------
            PULL_VAL(0)     => pull_valid      , -- Out :
            PULL_SIZE       => pull_size       , -- Out :
            PULL_LAST       => pull_last       , -- Out :
            PULL_ERROR      => pull_error      , -- Out :
        ---------------------------------------------------------------------------
        -- Read Buffer Interface Signals.
        ---------------------------------------------------------------------------
            BUF_REN         => open            , -- Out :
            BUF_DATA        => buf_rdata       , -- In  :
            BUF_PTR         => buf_rptr        , -- Out :
            BUF_RDY         => buf_rready
        );
    O_AWUSER         <= (others => '0');
    O_WUSER          <= (others => '0');
    o_req_burst_type <= AXI4_ABURST_FIXED when (O_ADDR_FIX = '1') else AXI4_ABURST_INCR;
    o_threshold_size <= std_logic_vector(to_unsigned(O_MAX_XFER_BYTES,SIZE_BITS));
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    CTRL: PUMP_CONTROLLER 
        generic map (
            I_CLK_RATE      => 1               , 
            I_REQ_ADDR_VALID=> 1               , 
            I_REQ_ADDR_BITS => I_ADDR_WIDTH    ,
            I_REG_ADDR_BITS => I_REG_ADDR_BITS ,
            I_REQ_SIZE_VALID=> 1               ,
            I_REQ_SIZE_BITS => I_REG_SIZE_BITS ,
            I_REG_SIZE_BITS => I_REG_SIZE_BITS ,
            I_REG_MODE_BITS => I_REG_MODE_BITS ,
            I_REG_STAT_BITS => I_REG_STAT_BITS ,
            O_CLK_RATE      => 1               , 
            O_REQ_ADDR_VALID=> 1               ,
            O_REQ_ADDR_BITS => O_ADDR_WIDTH    ,
            O_REG_ADDR_BITS => O_REG_ADDR_BITS ,
            O_REQ_SIZE_VALID=> 1               ,
            O_REQ_SIZE_BITS => O_REG_SIZE_BITS ,
            O_REG_SIZE_BITS => O_REG_SIZE_BITS ,
            O_REG_MODE_BITS => O_REG_MODE_BITS ,
            O_REG_STAT_BITS => O_REG_STAT_BITS ,
            BUF_DEPTH       => BUF_DEPTH       ,
            I2O_DELAY_CYCLE => 0
        )
        port map (
        ---------------------------------------------------------------------------
        -- Reset Signals.
        ---------------------------------------------------------------------------
            RST             => RST             , -- In  :
        ---------------------------------------------------------------------------
        -- Intake Clock and Clock Enable.
        ---------------------------------------------------------------------------
            I_CLK           => CLK             , -- In  :
            I_CLR           => CLR             , -- In  :
            I_CKE           => I_CKE           , -- In  :
        ---------------------------------------------------------------------------
        -- Intake Control Register Interface.
        ---------------------------------------------------------------------------
            I_ADDR_L        => I_ADDR_L        , -- In  :
            I_ADDR_D        => I_ADDR_D        , -- In  :
            I_ADDR_Q        => I_ADDR_Q        , -- Out :
            I_SIZE_L        => I_SIZE_L        , -- In  :
            I_SIZE_D        => I_SIZE_D        , -- In  :
            I_SIZE_Q        => I_SIZE_Q        , -- Out :
            I_MODE_L        => I_MODE_L        , -- In  :
            I_MODE_D        => I_MODE_D        , -- In  :
            I_MODE_Q        => I_MODE_Q        , -- Out :
            I_STAT_L        => I_STAT_L        , -- In  :
            I_STAT_D        => I_STAT_D        , -- In  :
            I_STAT_Q        => I_STAT_Q        , -- Out :
            I_STAT_I        => I_STAT_I        , -- In  :
            I_RESET_L       => I_RESET_L       , -- In  :
            I_RESET_D       => I_RESET_D       , -- In  :
            I_RESET_Q       => I_RESET_Q       , -- Out :
            I_START_L       => I_START_L       , -- In  :
            I_START_D       => I_START_D       , -- In  :
            I_START_Q       => I_START_Q       , -- Out :
            I_STOP_L        => I_STOP_L        , -- In  :
            I_STOP_D        => I_STOP_D        , -- In  :
            I_STOP_Q        => I_STOP_Q        , -- Out :
            I_PAUSE_L       => I_PAUSE_L       , -- In  :
            I_PAUSE_D       => I_PAUSE_D       , -- In  :
            I_PAUSE_Q       => I_PAUSE_Q       , -- Out :
            I_FIRST_L       => I_FIRST_L       , -- In  :
            I_FIRST_D       => I_FIRST_D       , -- In  :
            I_FIRST_Q       => I_FIRST_Q       , -- Out :
            I_LAST_L        => I_LAST_L        , -- In  :
            I_LAST_D        => I_LAST_D        , -- In  :
            I_LAST_Q        => I_LAST_Q        , -- Out :
            I_DONE_EN_L     => I_DONE_EN_L     , -- In  :
            I_DONE_EN_D     => I_DONE_EN_D     , -- In  :
            I_DONE_EN_Q     => I_DONE_EN_Q     , -- Out :
            I_DONE_ST_L     => I_DONE_ST_L     , -- In  :
            I_DONE_ST_D     => I_DONE_ST_D     , -- In  :
            I_DONE_ST_Q     => I_DONE_ST_Q     , -- Out :
            I_ERR_ST_L      => I_ERR_ST_L      , -- In  :
            I_ERR_ST_D      => I_ERR_ST_D      , -- In  :
            I_ERR_ST_Q      => I_ERR_ST_Q      , -- Out :
        ---------------------------------------------------------------------------
        -- Intake Configuration Signals.
        ---------------------------------------------------------------------------
            I_ADDR_FIX      => I_ADDR_FIX      , -- In  :
            I_THRESHOLD_SIZE=> i_threshold_size, -- In  :
        ---------------------------------------------------------------------------
        -- Outlet Clock and Clock Enable.
        ---------------------------------------------------------------------------
            O_CLK           => CLK             , -- In  :
            O_CLR           => CLR             , -- In  :
            O_CKE           => O_CKE           , -- In  :
        ---------------------------------------------------------------------------
        -- Outlet Control Register Interface.
        ---------------------------------------------------------------------------
            O_ADDR_L        => O_ADDR_L        , -- In  :
            O_ADDR_D        => O_ADDR_D        , -- In  :
            O_ADDR_Q        => O_ADDR_Q        , -- Out :
            O_SIZE_L        => O_SIZE_L        , -- In  :
            O_SIZE_D        => O_SIZE_D        , -- In  :
            O_SIZE_Q        => O_SIZE_Q        , -- Out :
            O_MODE_L        => O_MODE_L        , -- In  :
            O_MODE_D        => O_MODE_D        , -- In  :
            O_MODE_Q        => O_MODE_Q        , -- Out :
            O_STAT_L        => O_STAT_L        , -- In  :
            O_STAT_D        => O_STAT_D        , -- In  :
            O_STAT_Q        => O_STAT_Q        , -- Out :
            O_STAT_I        => O_STAT_I        , -- In  :
            O_RESET_L       => O_RESET_L       , -- In  :
            O_RESET_D       => O_RESET_D       , -- In  :
            O_RESET_Q       => O_RESET_Q       , -- Out :
            O_START_L       => O_START_L       , -- In  :
            O_START_D       => O_START_D       , -- In  :
            O_START_Q       => O_START_Q       , -- Out :
            O_STOP_L        => O_STOP_L        , -- In  :
            O_STOP_D        => O_STOP_D        , -- In  :
            O_STOP_Q        => O_STOP_Q        , -- Out :
            O_PAUSE_L       => O_PAUSE_L       , -- In  :
            O_PAUSE_D       => O_PAUSE_D       , -- In  :
            O_PAUSE_Q       => O_PAUSE_Q       , -- Out :
            O_FIRST_L       => O_FIRST_L       , -- In  :
            O_FIRST_D       => O_FIRST_D       , -- In  :
            O_FIRST_Q       => O_FIRST_Q       , -- Out :
            O_LAST_L        => O_LAST_L        , -- In  :
            O_LAST_D        => O_LAST_D        , -- In  :
            O_LAST_Q        => O_LAST_Q        , -- Out :
            O_DONE_EN_L     => O_DONE_EN_L     , -- In  :
            O_DONE_EN_D     => O_DONE_EN_D     , -- In  :
            O_DONE_EN_Q     => O_DONE_EN_Q     , -- Out :
            O_DONE_ST_L     => O_DONE_ST_L     , -- In  :
            O_DONE_ST_D     => O_DONE_ST_D     , -- In  :
            O_DONE_ST_Q     => O_DONE_ST_Q     , -- Out :
            O_ERR_ST_L      => O_ERR_ST_L      , -- In  :
            O_ERR_ST_D      => O_ERR_ST_D      , -- In  :
            O_ERR_ST_Q      => O_ERR_ST_Q      , -- Out :
        ---------------------------------------------------------------------------
        -- Intake Configuration Signals.
        ---------------------------------------------------------------------------
            O_ADDR_FIX      => O_ADDR_FIX      , -- In  :
            O_THRESHOLD_SIZE=> o_threshold_size, -- In  :
        ---------------------------------------------------------------------------
        -- Intake Transaction Command Request Signals.
        ---------------------------------------------------------------------------
            I_REQ_VALID     => i_req_valid     , -- Out :
            I_REQ_ADDR      => i_req_addr      , -- Out :
            I_REQ_SIZE      => i_req_size      , -- Out :
            I_REQ_BUF_PTR   => i_req_buf_ptr   , -- Out :
            I_REQ_FIRST     => i_req_first     , -- Out :
            I_REQ_LAST      => i_req_last      , -- Out :
            I_REQ_READY     => i_req_ready     , -- In  :
        ---------------------------------------------------------------------------
        -- Intake Transaction Command Acknowledge Signals.
        ---------------------------------------------------------------------------
            I_ACK_VALID     => i_ack_valid     , -- In  :
            I_ACK_SIZE      => i_ack_size      , -- In  :
            I_ACK_ERROR     => i_ack_error     , -- In  :
            I_ACK_NEXT      => i_ack_next      , -- In  :
            I_ACK_LAST      => i_ack_last      , -- In  :
            I_ACK_STOP      => i_ack_stop      , -- In  :
            I_ACK_NONE      => i_ack_none      , -- In  :
        ---------------------------------------------------------------------------
        -- Intake Flow Control Signals.
        ---------------------------------------------------------------------------
            I_FLOW_PAUSE    => i_flow_pause    , -- Out :
            I_FLOW_STOP     => i_flow_stop     , -- Out :
            I_FLOW_LAST     => i_flow_last     , -- Out :
            I_FLOW_SIZE     => i_flow_size     , -- Out :
            I_PUSH_VALID    => push_valid      , -- In  :
            I_PUSH_LAST     => push_last       , -- In  :
            I_PUSH_ERROR    => push_error      , -- In  :
            I_PUSH_SIZE     => push_size       , -- In  :
        ---------------------------------------------------------------------------
        -- Intake Status.
        ---------------------------------------------------------------------------
            I_OPEN          => I_OPEN          , -- Out :
            I_RUNNING       => I_RUNNING       , -- Out :
            I_DONE          => I_DONE          , -- Out :
            I_ERROR         => I_ERROR         , -- Out :
        ---------------------------------------------------------------------------
        -- Outlet Transaction Command Request Signals.
        ---------------------------------------------------------------------------
            O_REQ_VALID     => o_req_valid     , -- Out :
            O_REQ_ADDR      => o_req_addr      , -- Out :
            O_REQ_SIZE      => o_req_size      , -- Out :
            O_REQ_BUF_PTR   => o_req_buf_ptr   , -- Out :
            O_REQ_FIRST     => o_req_first     , -- Out :
            O_REQ_LAST      => o_req_last      , -- Out :
            O_REQ_READY     => o_req_ready     , -- In  :
        ---------------------------------------------------------------------------
        -- Outlet Transaction Command Response Signals.
        ---------------------------------------------------------------------------
            O_ACK_VALID     => o_ack_valid     , -- In  :
            O_ACK_SIZE      => o_ack_size      , -- In  :
            O_ACK_ERROR     => o_ack_error     , -- In  :
            O_ACK_NEXT      => o_ack_next      , -- In  :
            O_ACK_LAST      => o_ack_last      , -- In  :
            O_ACK_STOP      => o_ack_stop      , -- In  :
            O_ACK_NONE      => o_ack_none      , -- In  :
        ---------------------------------------------------------------------------
        -- Outlet Flow Control Signals.
        ---------------------------------------------------------------------------
            O_FLOW_PAUSE    => o_flow_pause    , -- Out :
            O_FLOW_STOP     => o_flow_stop     , -- Out :
            O_FLOW_LAST     => o_flow_last     , -- Out :
            O_FLOW_SIZE     => o_flow_size     , -- Out :
            O_PULL_VALID    => pull_valid      , -- In  :
            O_PULL_LAST     => pull_last       , -- In  :
            O_PULL_ERROR    => pull_error      , -- In  :
            O_PULL_SIZE     => pull_size       , -- In  :
        ---------------------------------------------------------------------------
        -- Outlet Status.
        ---------------------------------------------------------------------------
            O_OPEN          => O_OPEN          , -- Out :
            O_RUNNING       => O_RUNNING       , -- Out :
            O_DONE          => O_DONE          , -- Out :
            O_ERROR         => O_ERROR           -- Out :
        );
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    RAM: SDPRAM 
        generic map(
            DEPTH       => BUF_DEPTH+3         ,
            RWIDTH      => BUF_DATA_SIZE       , --
            WWIDTH      => BUF_DATA_SIZE       , --
            WEBIT       => BUF_DATA_SIZE-3     , --
            ID          => 0                     -- 
        )                                        -- 
        port map (                               -- 
            WCLK        => CLK                 , -- In  :
            WE          => buf_we              , -- In  :
            WADDR       => buf_wptr(BUF_DEPTH-1 downto BUF_DATA_SIZE-3), -- In  :
            WDATA       => buf_wdata           , -- In  :
            RCLK        => CLK                 , -- In  :
            RADDR       => buf_rptr(BUF_DEPTH-1 downto BUF_DATA_SIZE-3), -- In  :
            RDATA       => buf_rdata             -- Out :
        );
    buf_we <= buf_ben when (buf_wen = '1') else (others => '0');
end RTL;
