package com.greglu.helloworld;

import fi.iki.elonen.NanoHTTPD;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Very small HTTP application that mimics the behavior of a Dropwizard
 * application. Will read in a YAML config file and parse out the
 * "message" attribute, and serve that up through the root endpoint.
 * <p/>
 * This is used for testing that the dropwizard cookbook will start
 * up the application properly along with config files.
 */
public class HelloWorldApplication extends NanoHTTPD
{
	private static final Pattern MESSAGE_PATTERN = Pattern.compile("^\\s*message:\\s*(.*)$");
	private static final Pattern CHECK_PATTERN = Pattern.compile("^\\s*check:\\s*(.*)$");

	private final String message;

	private HelloWorldApplication(int port, String message)
	{
		super(port);
		this.message = message;
	}

	@Override
	public Response serve(IHTTPSession session)
	{
		return new Response(message);
	}

	private static void printUsage()
	{
		System.out.println("Usage:");
		System.out.println("- server <config.yml>");
		System.out.println("- check <config.yml>");
	}

	private static void printMessage(String message)
	{
		StringBuilder sb = new StringBuilder();
		for (int i = 0; i < message.length(); i++) {
			sb.append("=");
		}

		System.out.println(sb.toString());
		System.out.println(message);
		System.out.println(sb.toString());
	}

	private static String retrievePattern(Pattern pattern, BufferedReader reader) throws IOException
	{
		String line;
		while ((line = reader.readLine()) != null) {
			Matcher m = pattern.matcher(line);
			if (m.find() && m.groupCount() == 1) {
				return m.group(1).trim();
			}
		}
		return null;
	}

	private static String readConfigFile(String[] args) throws IOException
	{
		if (args.length == 2) {
			File configFile = new File(args[1]);

			if (!configFile.exists() || !configFile.isFile()) {
				printUsage();
				System.exit(1);
			}

			try (BufferedReader reader = new BufferedReader(new FileReader(configFile))) {
				// if it's a "check" command, we'll do an early exit
				if (args[0].equals("check")) {
					String checkValue = retrievePattern(CHECK_PATTERN, reader);
					if (checkValue != null) {
						int exitCode = Boolean.parseBoolean(checkValue) ? 0 : 1;
						if (exitCode == 0) {
							System.out.println("Configuration is OK");
						}
						System.exit(exitCode);
					} else {
						System.out.println("Configuration is OK");
						System.exit(0);
					}
				} else {
					String messageValue = retrievePattern(MESSAGE_PATTERN, reader);
					if (messageValue != null) {
						return messageValue;
					}
				}
			}
		}

		return "hello world";
	}

	public static void main(String[] args) throws IOException
	{
		if (args.length == 0 || args.length > 2) {
			printUsage();
			System.exit(1);
		}

		String message = readConfigFile(args);
		printMessage(message);

		final HelloWorldApplication server = new HelloWorldApplication(8080, message);

		Runtime.getRuntime().addShutdownHook(new Thread() {
			@Override
			public void run() {
				server.stop();
				System.out.println("Server stopped\n");
			}
		});

		try {
			server.start();
		} catch (IOException ioe) {
			System.err.println("Couldn't start server:\n" + ioe);
			System.exit(-1);
		}

		try {
			Thread.currentThread().join();
		} catch (Throwable ignored) {
		}
	}

}
