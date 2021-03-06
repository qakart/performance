package net.unit8.jmeter.protocol.socket_io.util;

import java.net.URL;

import net.unit8.jmeter.protocol.socket_io.sampler.SocketIOSampler;

import org.apache.jorphan.logging.LoggingManager;
import org.apache.log.Logger;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import io.socket.IOAcknowledge;
import io.socket.SocketIO;
import io.socket.SocketIOException;

public abstract class SocketIOAsyncActionBase {
    public static class SocketIOCallbackData {
        public String messageStr = null;
        public IOAcknowledge messageStrAck = null;
        public JsonElement messageJson = null;
        public IOAcknowledge messageJsonAck = null;
        public String event = null;
        public IOAcknowledge eventAck = null;
        public JsonElement[] eventArgs = null;
        public SocketIOException error = null;
    }
    
    protected static final JsonParser parser = new JsonParser();
    protected static final Logger log = LoggingManager.getLoggerForClass();
    protected int userIndex;
    protected IOAcknowledge ack = null;
    private Integer groupId = null;
    
    public SocketIOAsyncActionBase(int userIndex) {
        this.userIndex = userIndex;
        this.ack = new IOAcknowledge() {
            public void ack(JsonElement... args) {}
        };
    }
    
    public abstract SocketIOCallbackData[] run(SocketIOCallbackData[] datas, // data got from last action. Should be maintained and returned.
                                               SocketIOCallbackHandlerProxy[] handlers, // use to register handlers of users
                                               SocketIOUserInfo[] users, // user infos
                                               SocketIO[] sockets, // sockets corresponding to each user
                                               final SocketIOSampler sampler) throws Exception;
    
    protected int createOrGetGroupId(SocketIOUserInfo[] users, SocketIOSampler sampler) throws Exception {
        if (users.length < 2) {
            throw new Exception("Cannot create a group with less than two users.");
        }
        if (groupId == null) {
            String uids = "";
            for (int i = 1; i < users.length; i++) {
                if (i != userIndex)
                    uids = uids + "," + users[i].uid;
            }
            uids = uids.substring(1);

            URL url = sampler.getURI("/ws/group/create").toURL();
            String response = SocketIOSampler.makePostConnection(
                    url,"users=" + uids, "token=" + users[userIndex].token);

            JsonObject json = (JsonObject) parser.parse(response);
            JsonObject result = json.get("result").getAsJsonObject();
            groupId = result.get("group_id").getAsInt();
            log.info("Create group with id " + groupId.toString());
        }
        return groupId.intValue();
    }
}
